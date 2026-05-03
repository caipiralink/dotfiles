import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";

function resolveContextModePackageRoot() {
  const explicit = process.env.CONTEXT_MODE_PACKAGE_ROOT;
  if (explicit) return explicit;

  const shim = execFileSync("mise", ["which", "context-mode"], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
    timeout: 5000,
  }).trim();

  return join(dirname(shim), "node_modules", "context-mode");
}

const packageRoot = resolveContextModePackageRoot();
process.env.CONTEXT_MODE_PACKAGE_ROOT = packageRoot;

await import(pathToFileURL(join(packageRoot, "start.mjs")).href);
