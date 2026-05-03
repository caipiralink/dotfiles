import childProcess from "node:child_process";
import { syncBuiltinESMExports } from "node:module";

const parentEnv = { ...process.env };
const projectRoot =
  process.env.CONTEXT_MODE_PROJECT_DIR ||
  process.env.GEMINI_PROJECT_DIR ||
  process.env.VSCODE_CWD ||
  process.cwd();

const originalSpawn = childProcess.spawn;
const originalExecFileSync = childProcess.execFileSync;
const originalExecSync = childProcess.execSync;

function isContextModeTempDir(value) {
  return typeof value === "string" && /(^|[\\/])\.ctx-mode-[^\\/]+$/.test(value);
}

function patchExecOptions(options) {
  if (!options || typeof options !== "object") return options;

  const patched = { ...options };
  const sandboxEnv = patched.env && isContextModeTempDir(patched.env.TMPDIR);

  if (isContextModeTempDir(patched.cwd)) {
    patched.cwd = projectRoot;
  }

  if (sandboxEnv) {
    patched.env = { ...parentEnv };
  }

  return patched;
}

function patchSpawnArgs(args) {
  if (args.length < 3) return args;
  return [args[0], args[1], patchExecOptions(args[2])];
}

childProcess.spawn = function spawnNoSandbox(...args) {
  return originalSpawn.apply(this, patchSpawnArgs(args));
};

childProcess.execFileSync = function execFileSyncNoSandbox(command, args, options) {
  return originalExecFileSync.call(this, command, args, patchExecOptions(options));
};

childProcess.execSync = function execSyncNoSandbox(command, options) {
  return originalExecSync.call(this, command, patchExecOptions(options));
};

syncBuiltinESMExports();
