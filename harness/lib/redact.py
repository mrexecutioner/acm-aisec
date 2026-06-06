#!/usr/bin/env python3
"""redact.py - strip identifying info from transcripts before commit.

Removes (in-place or stream):
  - The current OS username and the user home prefix
  - The machine hostname
  - Common absolute-path prefixes that reveal identity (/home/<u>, /Users/<u>,
    C:\\Users\\<u>)
  - Bearer tokens (best-effort: 'Authorization: Bearer ...' becomes '...REDACTED')

Replacements are deterministic: <REDACTED:USER>, <REDACTED:HOST>, <REDACTED:PATH>.

Usage:
  python3 redact.py path/to/file [path/to/file ...]   # in-place
  cat x | python3 redact.py -                         # stream
  python3 redact.py --selftest
"""
from __future__ import annotations
import os
import re
import socket
import sys
from pathlib import Path

def _replacements() -> list[tuple[re.Pattern, str]]:
    user = os.environ.get("USER") or os.environ.get("USERNAME") or ""
    host = socket.gethostname()
    home = os.path.expanduser("~")

    pats: list[tuple[re.Pattern, str]] = []
    if user:
        pats.append((re.compile(re.escape(user)), "<REDACTED:USER>"))
    if host:
        pats.append((re.compile(re.escape(host)), "<REDACTED:HOST>"))
    if home:
        # Backslash-aware: works for both POSIX and Windows paths
        pats.append((re.compile(re.escape(home)), "<REDACTED:PATH>"))
    # Generic Windows / POSIX user-home prefixes
    pats.append((re.compile(r"[A-Za-z]:\\Users\\[^\\\s\"']+"), "<REDACTED:PATH>"))
    pats.append((re.compile(r"/home/[^/\s\"']+"), "<REDACTED:PATH>"))
    pats.append((re.compile(r"/Users/[^/\s\"']+"), "<REDACTED:PATH>"))
    # Bearer tokens
    pats.append((re.compile(r"(?i)(Authorization:\s*Bearer\s+)\S+"),
                 r"\1<REDACTED:TOKEN>"))
    return pats

PATS = _replacements()

def redact(text: str) -> str:
    for pat, repl in PATS:
        text = pat.sub(repl, text)
    return text

def selftest() -> int:
    samples = [
        ("C:\\Users\\alice\\file.txt", "<REDACTED:PATH>"),
        ("/home/bob/x",                 "<REDACTED:PATH>"),
        ("/Users/carol/y",              "<REDACTED:PATH>"),
        ("Authorization: Bearer abc123","<REDACTED:TOKEN>"),
    ]
    failed = 0
    for src, must_contain in samples:
        out = redact(src)
        if must_contain not in out:
            print(f"selftest FAIL: input={src!r} got={out!r}")
            failed += 1
    if failed == 0:
        print("redact.py selftest OK")
        return 0
    return 1

def main(argv: list[str]) -> int:
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__)
        return 0
    if argv[0] == "--selftest":
        return selftest()
    rc = 0
    for arg in argv:
        if arg == "-":
            sys.stdout.write(redact(sys.stdin.read()))
            continue
        p = Path(arg)
        if not p.is_file():
            print(f"skip (not a file): {arg}", file=sys.stderr); rc = 1; continue
        try:
            txt = p.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"read failed {arg}: {e}", file=sys.stderr); rc = 1; continue
        p.write_text(redact(txt), encoding="utf-8")
    return rc

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
