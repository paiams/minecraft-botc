import java.io.IOException;
import java.net.BindException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.concurrent.TimeUnit;

/** One-window lifecycle manager for the local BotC server, broadcast demo, and OBS tunnel. */
public final class BotcStack {
    private final Path repo;
    private final Path broadcast;
    private final Path serverDir;
    private final Path serverScript;
    private final Path pidFile;
    private final Path stopFile;

    private Process server;
    private Process demo;
    private Process tunnel;

    private BotcStack(Path repo) {
        this.repo = repo.toAbsolutePath().normalize();
        this.broadcast = this.repo.getParent().resolve("minecraft-botc-broadcast").normalize();
        this.serverDir = this.repo.resolve("server");
        this.serverScript = this.repo.resolve("start.cmd");
        this.pidFile = this.serverDir.resolve(".botc-stack.pid");
        this.stopFile = this.serverDir.resolve(".botc-stack.stop");
    }

    private void validate() throws IOException {
        for (Path path : List.of(serverScript, broadcast.resolve("gradlew.bat"), serverDir.resolve("fabric-server-launch.jar"))) {
            if (!Files.isRegularFile(path)) throw new IOException("Missing required file: " + path);
        }
    }

    private static boolean portInUse(int port) {
        try (ServerSocket socket = new ServerSocket()) {
            socket.setReuseAddress(false);
            socket.bind(new InetSocketAddress("127.0.0.1", port));
            return false;
        } catch (BindException e) {
            return true;
        } catch (IOException e) {
            return true;
        }
    }

    private Process startScript(Path script, String... arguments) throws IOException {
        StringBuilder command = new StringBuilder("call \"").append(script).append("\"");
        for (String argument : arguments) command.append(' ').append(argument);
        ProcessBuilder builder = new ProcessBuilder(
            System.getenv().getOrDefault("ComSpec", "cmd.exe"), "/d", "/s", "/c", command.toString());
        builder.directory(script.getParent().toFile());
        builder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
        builder.redirectError(ProcessBuilder.Redirect.INHERIT);
        return builder.start();
    }

    private void waitForCore() throws Exception {
        System.out.println("Waiting for Minecraft, live broadcast, and the standalone demo...");
        Instant deadline = Instant.now().plus(Duration.ofSeconds(60));
        while (!(portInUse(25565) && portInUse(8771) && portInUse(8770))) {
            if (!server.isAlive()) throw new IOException("Minecraft server exited during startup with code " + server.exitValue());
            if (!demo.isAlive()) throw new IOException("Broadcast demo exited during startup with code " + demo.exitValue());
            if (Files.exists(stopFile)) return;
            if (Instant.now().isAfter(deadline)) throw new IOException("BotC stack startup timed out.");
            Thread.sleep(250);
        }
    }

    private void waitForTunnel() throws Exception {
        Instant deadline = Instant.now().plus(Duration.ofSeconds(20));
        while (!externalOverlayReady()) {
            if (!tunnel.isAlive()) throw new IOException("OBS tunnel exited during startup with code " + tunnel.exitValue());
            if (Files.exists(stopFile)) return;
            if (Instant.now().isAfter(deadline)) throw new IOException("OBS tunnel did not establish within 20 seconds.");
            Thread.sleep(500);
        }
    }

    private boolean externalOverlayReady() {
        try {
            String url = "https://obs.dotmario.com/overlay?component=roles";
            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(2)).build();
            HttpRequest request = HttpRequest.newBuilder(URI.create(url)).timeout(Duration.ofSeconds(3)).GET().build();
            return client.send(request, HttpResponse.BodyHandlers.discarding()).statusCode() == 200;
        } catch (Exception ignored) {
            return false;
        }
    }

    private void startConsoleStopReader() {
        Thread input = new Thread(() -> {
            try {
                byte[] buffer = new byte[128];
                while (true) {
                    int count = System.in.read(buffer);
                    if (count < 0) return;
                    String text = new String(buffer, 0, count, StandardCharsets.UTF_8).trim();
                    if (text.equalsIgnoreCase("q") || text.equalsIgnoreCase("stop")) {
                        Files.writeString(stopFile, "stop", StandardCharsets.UTF_8);
                        return;
                    }
                }
            } catch (IOException ignored) {
            }
        }, "botc-stack-console");
        input.setDaemon(true);
        input.start();
    }

    private static void forceTree(Process process, String name) {
        if (process == null || !process.isAlive()) return;
        System.out.println("Stopping " + name + " (PID " + process.pid() + ")...");
        try {
            Process killer = new ProcessBuilder("taskkill.exe", "/PID", Long.toString(process.pid()), "/T", "/F")
                .redirectOutput(ProcessBuilder.Redirect.INHERIT)
                .redirectError(ProcessBuilder.Redirect.INHERIT)
                .start();
            boolean finished = killer.waitFor(10, TimeUnit.SECONDS);
            if (!finished) killer.destroyForcibly();
            process.waitFor(2, TimeUnit.SECONDS);
            if ((!finished || killer.exitValue() != 0) && process.isAlive()) {
                throw new IOException("taskkill did not terminate PID " + process.pid());
            }
        } catch (Exception e) {
            System.err.println("WARNING: taskkill fallback for " + name + ": " + e.getMessage());
            process.toHandle().descendants().forEach(ProcessHandle::destroyForcibly);
            process.destroyForcibly();
        }
    }

    private static void stopDetachedDemoProcesses() {
        ProcessHandle.allProcesses()
            .filter(process -> process.info().commandLine().orElse("").contains("com.paiams.botc.broadcast.Demo"))
            .forEach(ProcessHandle::destroyForcibly);
    }

    private void shutdown() {
        try {
            if (server != null && server.isAlive()) {
                System.out.println("Stopping Minecraft safely...");
                server.getOutputStream().write("stop\r\n".getBytes(StandardCharsets.UTF_8));
                server.getOutputStream().flush();
                if (!server.waitFor(30, TimeUnit.SECONDS)) {
                    System.err.println("WARNING: Minecraft did not stop normally; forcing the remaining process tree down.");
                    forceTree(server, "Minecraft server");
                }
            }
        } catch (Exception e) {
            System.err.println("WARNING: Minecraft shutdown issue: " + e.getMessage());
            forceTree(server, "Minecraft server");
        }
        forceTree(tunnel, "OBS tunnel");
        forceTree(demo, "broadcast demo");
        stopDetachedDemoProcesses();
        try { Files.deleteIfExists(pidFile); } catch (IOException ignored) {}
        try { Files.deleteIfExists(stopFile); } catch (IOException ignored) {}
        System.out.println("BotC stack stopped.");
    }

    private int run() {
        try {
            validate();
            Files.writeString(pidFile, Long.toString(ProcessHandle.current().pid()), StandardCharsets.US_ASCII);
            Files.deleteIfExists(stopFile);

            if (portInUse(25565)) throw new IOException("Minecraft port 25565 is already in use.");
            if (portInUse(8770)) throw new IOException("Broadcast demo port 8770 is already in use.");
            if (portInUse(8771)) throw new IOException("Live broadcast port 8771 is already in use.");
            System.out.println("Starting BotC stack in one managed window...");
            System.out.println("  Minecraft server : 25565 / live broadcast 8771");
            System.out.println("  Broadcast demo   : 8770");
            System.out.println("  External OBS     : obs.dotmario.com");
            System.out.println();

            server = startScript(serverScript, "server", "--managed");
            demo = startScript(serverScript, "demo", "--managed");
            waitForCore();
            if (Files.exists(stopFile)) return 0;

            tunnel = startScript(serverScript, "tunnel", "--managed");
            waitForTunnel();
            if (Files.exists(stopFile)) return 0;

            System.out.println();
            System.out.println("BotC stack is running.");
            System.out.println("Double-click start.cmd again to stop EVERYTHING.");
            System.out.println("You can also type q then Enter in this window.");
            startConsoleStopReader();

            while (!Files.exists(stopFile)) {
                if (!server.isAlive()) throw new IOException("Minecraft server exited unexpectedly.");
                if (!demo.isAlive()) throw new IOException("Broadcast demo exited unexpectedly.");
                if (!tunnel.isAlive()) throw new IOException("OBS tunnel exited unexpectedly.");
                Thread.sleep(250);
            }
            return 0;
        } catch (Exception e) {
            System.err.println("[ERROR] " + e.getMessage());
            return 1;
        } finally {
            shutdown();
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("Usage: java BotcStack.java <minecraft-botc-dir> [--check]");
            System.exit(2);
        }
        BotcStack stack = new BotcStack(Path.of(args[0]));
        if (args.length > 1 && args[1].equalsIgnoreCase("--check")) {
            stack.validate();
            System.out.println("[OK] Minecraft server: " + stack.serverScript);
            System.out.println("[OK] OBS tunnel:      " + stack.serverScript + " tunnel");
            System.out.println("[OK] Broadcast demo:  " + stack.broadcast.resolve("gradlew.bat"));
            System.out.println("[OK] Manager: Java " + Runtime.version().feature() + ", one-window start/stop mode.");
            return;
        }
        System.exit(stack.run());
    }
}
