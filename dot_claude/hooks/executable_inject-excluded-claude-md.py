#!/usr/bin/env python3
import glob
import json
import os
import sys
from pathlib import Path


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    settings_path = os.path.join(cwd, ".claude", "settings.local.json")
    if not os.path.isfile(settings_path):
        sys.exit(0)

    try:
        with open(settings_path, encoding="utf-8") as f:
            settings = json.load(f)
    except Exception:
        sys.exit(0)

    patterns = settings.get("claudeMdExcludes") or []
    if not patterns:
        sys.exit(0)

    home_claude = (Path.home() / ".claude").resolve()

    # Only instruction-like files under ~/.claude/ are considered. Session
    # state, caches, telemetry, etc. are excluded even when matched by the
    # user's patterns.
    ALLOWED_ROOT_FILES = {"CLAUDE.md"}
    ALLOWED_SUBDIRS = {"rules", "skills", "commands", "agents", "output-styles"}

    def is_instruction_file(rel: Path) -> bool:
        parts = rel.parts
        if len(parts) == 1:
            return parts[0] in ALLOWED_ROOT_FILES
        return parts[0] in ALLOWED_SUBDIRS and rel.suffix.lower() == ".md"

    sections = []
    seen = set()
    for pattern in patterns:
        expanded = os.path.expanduser(pattern)
        for match in glob.glob(expanded, recursive=True):
            if not os.path.isfile(match):
                continue
            real = Path(match).resolve()
            try:
                rel = real.relative_to(home_claude)
            except ValueError:
                continue
            if not is_instruction_file(rel):
                continue
            if real in seen:
                continue
            seen.add(real)
            try:
                content = real.read_text(encoding="utf-8")
            except Exception:
                continue
            sections.append(f"### {real}\n\n{content}")

    if not sections:
        sys.exit(0)

    header = (
        "The following files from the user's home ~/.claude/ directory were "
        "excluded by this project's `claudeMdExcludes` setting. They represent "
        "the user's standing preferences and should be applied alongside "
        "project-level instructions.\n\n"
    )
    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": header + "\n\n".join(sections),
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
