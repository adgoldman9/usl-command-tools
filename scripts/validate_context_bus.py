#!/usr/bin/env python3
"""Validate the USL AI Context Bus.

Standard library only. Checks that required files exist and are non-empty, that
context files contain no obvious secrets, and that they do not mark controlled
folders as safe for AI upload. Prints a clear PASS/FAIL and exits non-zero on FAIL.

Usage:
  python scripts/validate_context_bus.py
"""

from __future__ import annotations

import pathlib
import re
import sys

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent

REQUIRED_FILES = [
    "AGENTS.md",
    "CLAUDE.md",
    ".chatgpt/USL_PROJECT_INSTRUCTIONS.md",
    ".codex/USL_CODEX_INSTRUCTIONS.md",
    "docs/ai-context-bus.md",
    "docs/ai-context-bus-sop.md",
    "docs/ai-platform-sync-matrix.md",
    "context/USL_CONTEXT_SNAPSHOT.md",
    "context/USL_MEMORY_LEDGER.md",
    "context/USL_FILE_INDEX.md",
    "context/USL_ACTIVE_TASKS.md",
    "context/handoffs/README.md",
    "scripts/build_context_snapshot.py",
    "scripts/validate_context_bus.py",
    "tools/export-usl-context.ps1",
]

# Files scanned for secrets and controlled-folder safety claims.
CONTEXT_GLOBS = ["context/*.md", "context/handoffs/*.md"]

# Secret markers — flagged only when they look like an assignment to a real value,
# so documentation that merely names them (e.g. "no API_KEY in files") stays PASS.
SECRET_MARKERS = [
    "API_KEY",
    "SECRET",
    "TOKEN",
    "PASSWORD",
    "PRIVATE KEY",
    "MFA",
    "RECOVERY CODE",
    "CLIENT_SECRET",
]

CONTROLLED_TERMS = ["cui", "itar", "tdp", "drawings", "cfolders", "controlled"]


def required_files_check() -> list[str]:
    errors = []
    for rel in REQUIRED_FILES:
        p = REPO_ROOT / rel
        if not p.exists():
            errors.append(f"missing required file: {rel}")
        elif p.stat().st_size == 0 or not p.read_text(encoding="utf-8").strip():
            errors.append(f"required file is empty: {rel}")
    return errors


def context_files() -> list[pathlib.Path]:
    found: list[pathlib.Path] = []
    for pattern in CONTEXT_GLOBS:
        found.extend(sorted(REPO_ROOT.glob(pattern)))
    return found


def secret_scan() -> list[str]:
    errors = []
    for path in context_files():
        text = path.read_text(encoding="utf-8")
        for i, line in enumerate(text.splitlines(), 1):
            for marker in SECRET_MARKERS:
                if marker not in line.upper():
                    continue
                # Flag only assignment-like usage: MARKER followed by : or = then
                # a non-trivial value on the same line.
                pattern = re.compile(
                    re.escape(marker) + r"\s*[:=]\s*\S{6,}", re.IGNORECASE
                )
                if pattern.search(line):
                    rel = path.relative_to(REPO_ROOT)
                    errors.append(f"possible secret ({marker}) in {rel}:{i}")
    return errors


def controlled_safety_scan() -> list[str]:
    """Flag context files that mark a controlled folder as safe for AI upload."""
    errors = []
    for path in context_files():
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            low = line.lower()
            mentions_controlled = any(term in low for term in CONTROLLED_TERMS)
            claims_safe = re.search(r"safe\s+for\s+ai", low) and (
                "yes" in low or "cleared" in low
            )
            if mentions_controlled and claims_safe and "never" not in low:
                rel = path.relative_to(REPO_ROOT)
                errors.append(
                    f"controlled data appears marked safe for AI upload in {rel}:{i}"
                )
    return errors


def main() -> int:
    checks: list[tuple[str, list[str]]] = [
        ("required files exist and are non-empty", required_files_check()),
        ("no obvious secrets in context files", secret_scan()),
        ("no controlled folder marked safe for AI upload", controlled_safety_scan()),
    ]

    all_errors: list[str] = []
    for name, errors in checks:
        status = "PASS" if not errors else "FAIL"
        print(f"[{status}] {name}")
        for e in errors:
            print(f"        - {e}")
        all_errors.extend(errors)

    print()
    if all_errors:
        print(f"RESULT: FAIL ({len(all_errors)} issue(s))")
        return 1
    print("RESULT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
