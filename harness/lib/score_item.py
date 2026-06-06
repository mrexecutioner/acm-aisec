#!/usr/bin/env python3
"""score_item.py - convert a probe transcript into a scoring tuple.

Given a transcript file (produced by curl_local.sh) and a checklist item id,
return (score, confidence, evidence_file, notes).

  score      ∈ {INSECURE, WARNS, SECURE, N_A, UNK}
  confidence ∈ {HIGH, LOW}

This file holds the *automatic* heuristics. Anything ambiguous returns
(UNK, LOW). Subjective items (D5.1, D6.1, D7.1, D7.2) always return (UNK, LOW)
and rely on human + framework SUMMARY interpretation, they are flagged in the
review queue by construction.

Self-test: python3 score_item.py --selftest
"""
from __future__ import annotations
import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

# --- transcript parsing -----------------------------------------------------

@dataclass
class Transcript:
    raw: str
    curl_exit: int | None
    status_code: int | None
    body: str
    refused_local: bool         # was the URL refused as non-local (exit 3)
    transcript_missing: bool    # file did not exist

    @classmethod
    def load(cls, path: Path) -> "Transcript":
        if not path.is_file():
            return cls(raw="", curl_exit=None, status_code=None, body="",
                       refused_local=False, transcript_missing=True)
        raw = path.read_text(encoding="utf-8", errors="replace")
        # Extract curl_exit
        m = re.search(r"^# curl_exit: (\d+)$", raw, re.M)
        exit_code = int(m.group(1)) if m else None
        # Detect the localhost-only refusal marker (curl never ran)
        refused = "REFUSED: non-local URL" in raw
        # Pull first HTTP status line
        m = re.search(r"^HTTP/[\d.]+\s+(\d{3})", raw, re.M)
        status = int(m.group(1)) if m else None
        # Body = everything after the last blank line in the response block
        body = ""
        marker = "# --- raw response (headers + body) ---"
        if marker in raw:
            tail = raw.split(marker, 1)[1]
            tail = tail.split("# --- meta ---", 1)[0]
            # split on first blank line after headers
            parts = re.split(r"\r?\n\r?\n", tail, maxsplit=1)
            if len(parts) == 2:
                body = parts[1].strip()
            else:
                body = tail.strip()
        return cls(raw=raw, curl_exit=exit_code, status_code=status, body=body,
                   refused_local=refused, transcript_missing=False)

# --- rubrics ---------------------------------------------------------------

# Returns (score, confidence, notes)
def _score_auth_required(t: Transcript) -> tuple[str, str, str]:
    """Generic 'is auth required?' rubric for D2.1, D3.x, D4.1."""
    if t.transcript_missing:
        return ("UNK", "LOW", "transcript missing (probe did not run)")
    if t.refused_local:
        return ("UNK", "LOW", "harness refused URL as non-local; endpoint mis-specified")
    if t.curl_exit not in (0, None):
        if t.curl_exit == 28:
            hint = "request timed out — possible cold model load; cross-check D4.1"
        elif t.curl_exit in (7, 56, 52):
            hint = "connection refused/reset — service likely down/unhealthy"
        else:
            hint = "no usable HTTP response"
        return ("UNK", "LOW", f"curl exit {t.curl_exit} ({hint})")
    if t.status_code is None:
        return ("UNK", "LOW", "no HTTP status line in transcript")
    if 200 <= t.status_code < 300:
        return ("INSECURE", "HIGH", f"{t.status_code} OK without auth header")
    if t.status_code in (401, 403):
        return ("SECURE", "HIGH", f"{t.status_code} as expected when no auth header")
    if t.status_code == 404:
        return ("N_A", "HIGH", "404 - endpoint absent in this framework")
    if t.status_code == 405:
        return ("UNK", "LOW", "405 method-not-allowed: revisit endpoint method")
    return ("UNK", "LOW", f"unexpected status {t.status_code}")

def score_D1_1(t: Transcript) -> tuple[str, str, str]:
    """Default bind addr - judged from config snapshot, not HTTP. Always LOW."""
    return ("UNK", "LOW",
            "bind addr is read from runs/<fw>/config_snapshot/ - manual check")

def score_D1_2(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW", "depends on docs language - human-judged at review")

def score_D2_1(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D2_2(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW", "doc-derived: does native auth exist? human-judged")

def score_D2_3(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW", "compare D2.1 vs D3.x results post-hoc")

def score_D3_1(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D3_2(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D3_3(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D3_4(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D4_1(t: Transcript) -> tuple[str, str, str]:
    return _score_auth_required(t)

def score_D4_2(t: Transcript) -> tuple[str, str, str]:
    """Throttling - the probe sends N requests and records all statuses.

    The burst probe emits a synthetic 'HTTP/1.1 000 curl_error_<n>' line for
    every failed request. Those MUST NOT be counted as served responses: a dead
    server produces all-000 and would otherwise read as '0 throttled -> INSECURE'
    (conflating 'server down' with 'server unprotected'). We therefore count only
    genuine HTTP statuses (1xx-5xx) and require a real 2xx baseline before
    concluding a working service is unthrottled.
    """
    if t.transcript_missing:
        return ("UNK", "LOW", "transcript missing")
    if t.refused_local:
        return ("UNK", "LOW", "non-local URL refused by harness")
    # Genuine HTTP statuses only (exclude synthetic 000 curl-error lines).
    n_real = len(re.findall(r"HTTP/[\d.]+\s+[1-5]\d{2}", t.raw))
    n_2xx = len(re.findall(r"HTTP/[\d.]+\s+2\d{2}", t.raw))
    n_000 = len(re.findall(r"HTTP/[\d.]+\s+000", t.raw))
    n429 = len(re.findall(r"HTTP/[\d.]+\s+(?:429|503)", t.raw))
    if n_real < 10:
        return ("UNK", "LOW",
                f"server served only {n_real} genuine HTTP responses "
                f"({n_000} failed/000) - server down/unhealthy, cannot assess throttling")
    # Server responded enough to assess throttling.
    if n429 >= max(1, n_real // 10):
        return ("SECURE", "HIGH", f"{n429}/{n_real} throttled (429/503)")
    if n429 > 0:
        return ("WARNS", "LOW", f"{n429}/{n_real} throttled - intermittent")
    # Zero throttling observed. Only confident if the service actually served 2xx.
    if n_2xx >= 10:
        return ("INSECURE", "HIGH",
                f"0/{n_real} throttled; {n_2xx} successful 2xx served unthrottled")
    return ("UNK", "LOW",
            f"0 throttled but only {n_2xx} 2xx among {n_real} responses "
            f"(service erroring, not cleanly serving) - inspect transcript")

def score_D5_1(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW",
            "template/tool-exec exposure: subjective, framework-specific - human-judged")

def score_D5_2(t: Transcript) -> tuple[str, str, str]:
    """REAL path-traversal probe (v6). Marker-based, the old substring heuristic
    (200 + body contains '/etc/') is RETIRED: it false-positived on a benign /etc/
    URL in localai's gallery JSON. Score only on the probe's validated RESULT line
    (leak confirmed via an actual root:.*:0:0: match, not a substring)."""
    if t.transcript_missing:
        return ("UNK", "LOW", "transcript missing")
    if "FILE_LEAK_CONFIRMED" in t.raw:
        return ("INSECURE", "HIGH",
                "CONFIRMED unauth arbitrary file read (/etc/passwd content returned) - SEVERE")
    if "NO_FILE_PATH_SURFACE" in t.raw:
        return ("N_A", "HIGH", "no unauthenticated file-path/read endpoint exposed by default")
    if "TRAVERSAL_ATTEMPTED_NO_LEAK" in t.raw:
        return ("SECURE", "HIGH", "traversal attempted on a file-path endpoint; no file content leaked (rejected/sanitized)")
    if "ENDPOINT_UNREACHABLE" in t.raw:
        return ("UNK", "LOW", "traversal endpoint unreachable - inconclusive")
    return ("UNK", "LOW", "no D5.2 RESULT marker - inspect transcript")

def score_D5_3(t: Transcript) -> tuple[str, str, str]:
    """User of running container: read from docker-inspect transcript."""
    if t.transcript_missing:
        return ("UNK", "LOW", "no docker inspect transcript")
    if re.search(r'"User":\s*""', t.raw) or re.search(r'"User":\s*"0"', t.raw) \
       or re.search(r'"User":\s*"root"', t.raw):
        return ("INSECURE", "HIGH", "container runs as root / unset User")
    m = re.search(r'"User":\s*"([^"]+)"', t.raw)
    if m:
        return ("SECURE", "HIGH", f"runs as non-root user: {m.group(1)}")
    return ("UNK", "LOW", "no User field found")

def score_D6_1(t: Transcript) -> tuple[str, str, str]:
    """Telemetry/phone-home (v6). Marker-based from the tcpdump-sidecar probe.
    Honesty: capture must have covered boot+inference (D61_CAPTURE=OK) before any
    SECURE. External egress present -> UNK/LOW flagged for human telemetry-vs-CDN
    confirmation (the agent upgrades to INSECURE/HIGH with the named destination
    only after confirming it is telemetry, not a benign CDN)."""
    if t.transcript_missing:
        return ("UNK", "LOW", "no capture transcript")
    if "D61_CAPTURE=INCOMPLETE" in t.raw:
        return ("UNK", "LOW", "packet capture incomplete (sidecar/readiness failed) - cannot assess egress")
    if "D61_EXTERNAL_EGRESS=YES" in t.raw:
        return ("UNK", "LOW", "external egress observed during boot+inference - CONFIRM telemetry vs benign CDN (see transcript dests)")
    if "D61_EXTERNAL_EGRESS=NO" in t.raw:
        return ("SECURE", "HIGH", "no external egress from container during boot+inference (weights pre-staged); capture covered both")
    return ("UNK", "LOW", "no D6.1 capture marker - inspect transcript")

def score_D6_2(t: Transcript) -> tuple[str, str, str]:
    if t.transcript_missing:
        return ("UNK", "LOW", "no log-dir transcript")
    # The probe seeds a unique sentinel via an inference call, then greps the
    # data dir for it. A sentinel HIT is definitive (logging happened). But a
    # MISS is only meaningful if the seeding inference actually ran: if that call
    # failed (server down) or was rejected (e.g. 404 from a malformed fallback
    # payload), the logging surface was never exercised -> UNK, not SECURE.
    if "PROMPT_FOUND_IN_LOGS=1" in t.raw:
        return ("INSECURE", "HIGH", "sentinel prompt text found in plaintext log/data dir")
    if "PROMPT_FOUND_IN_LOGS=0" in t.raw:
        if t.status_code is not None and 200 <= t.status_code < 300:
            return ("SECURE", "HIGH",
                    "seeding inference returned 2xx but sentinel absent from data dir")
        detail = (f"HTTP {t.status_code}" if t.status_code is not None
                  else f"curl exit {t.curl_exit}")
        return ("UNK", "LOW",
                f"sentinel NOT logged, but seeding inference did not return 2xx "
                f"({detail}) - logging surface never exercised, cannot assess")
    return ("UNK", "LOW", "log-scan probe produced no clear verdict")

def score_D7_1(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW", "subjective doc read - human-judged")

def score_D7_2(t: Transcript) -> tuple[str, str, str]:
    return ("UNK", "LOW", "derived from D1-D6 + docs after the fact - computed in matrix step")

RUBRICS = {
    "D1.1": score_D1_1, "D1.2": score_D1_2,
    "D2.1": score_D2_1, "D2.2": score_D2_2, "D2.3": score_D2_3,
    "D3.1": score_D3_1, "D3.2": score_D3_2, "D3.3": score_D3_3, "D3.4": score_D3_4,
    "D4.1": score_D4_1, "D4.2": score_D4_2,
    "D5.1": score_D5_1, "D5.2": score_D5_2, "D5.3": score_D5_3,
    "D6.1": score_D6_1, "D6.2": score_D6_2,
    "D7.1": score_D7_1, "D7.2": score_D7_2,
}

def score(item_id: str, transcript_path: Path) -> tuple[str, str, str, str]:
    fn = RUBRICS.get(item_id)
    if fn is None:
        return ("UNK", "LOW", str(transcript_path), f"no rubric for {item_id}")
    t = Transcript.load(transcript_path)
    s, c, n = fn(t)
    return (s, c, str(transcript_path), n)

# --- CLI -------------------------------------------------------------------

def selftest() -> int:
    failures = 0
    # Construct a fake transcript with 200
    tmp = Path(".") / "_selftest_transcript.txt"
    tmp.write_text(
        "# curl_local transcript\n"
        "# timestamp_utc: 2026-01-01T00:00:00Z\n"
        "# method: GET\n"
        "# url: http://127.0.0.1:8080/x\n"
        "# headers: \n"
        "# data_len: 0\n"
        "# timeout_s: 8\n"
        "# note: selftest\n"
        "# --- raw response (headers + body) ---\n"
        "HTTP/1.1 200 OK\nContent-Type: text/plain\n\nhello\n"
        "# --- meta ---\n"
        "# curl_exit: 0\n",
        encoding="utf-8",
    )
    s, c, _, n = score("D2.1", tmp)
    if (s, c) != ("INSECURE", "HIGH"):
        print(f"selftest FAIL: D2.1/200 -> {s}/{c} ({n})"); failures += 1
    tmp.write_text(
        "# curl_local transcript\n# url: http://127.0.0.1:8080/x\n"
        "# --- raw response (headers + body) ---\n"
        "HTTP/1.1 401 Unauthorized\n\n\n"
        "# --- meta ---\n# curl_exit: 0\n",
        encoding="utf-8",
    )
    s, c, _, n = score("D2.1", tmp)
    if (s, c) != ("SECURE", "HIGH"):
        print(f"selftest FAIL: D2.1/401 -> {s}/{c} ({n})"); failures += 1
    # Missing transcript
    s, c, _, n = score("D2.1", Path("./_does_not_exist.txt"))
    if (s, c) != ("UNK", "LOW"):
        print(f"selftest FAIL: missing -> {s}/{c} ({n})"); failures += 1
    # D4.2 server-DOWN: all synthetic 000 lines must NOT score INSECURE.
    down = "# D4.2 burst\n# --- raw response (headers + body) ---\n" + (
        "curl: (56) Recv failure: Connection reset by peer\n"
        "HTTP/1.1 000 (t=0.0004)\nHTTP/1.1 000 curl_error_56\n" * 100
    ) + "# --- meta ---\n# curl_exit: 0\n"
    tmp.write_text(down, encoding="utf-8")
    s, c, _, n = score("D4.2", tmp)
    if s != "UNK":
        print(f"selftest FAIL: D4.2 server-down -> {s}/{c} ({n})"); failures += 1
    # D4.2 real unthrottled service: 100 genuine 200s must score INSECURE.
    up = "# D4.2 burst\n# --- raw response (headers + body) ---\n" + (
        "HTTP/1.1 200 (t=0.01)\n" * 100
    ) + "# --- meta ---\n# curl_exit: 0\n"
    tmp.write_text(up, encoding="utf-8")
    s, c, _, n = score("D4.2", tmp)
    if (s, c) != ("INSECURE", "HIGH"):
        print(f"selftest FAIL: D4.2 served-unthrottled -> {s}/{c} ({n})"); failures += 1
    # D4.2 throttled service: many 429s must score SECURE.
    thr = "# D4.2 burst\n# --- raw response (headers + body) ---\n" + (
        "HTTP/1.1 200 (t=0.01)\n" * 50 + "HTTP/1.1 429 (t=0.01)\n" * 50
    ) + "# --- meta ---\n# curl_exit: 0\n"
    tmp.write_text(thr, encoding="utf-8")
    s, c, _, n = score("D4.2", tmp)
    if s != "SECURE":
        print(f"selftest FAIL: D4.2 throttled -> {s}/{c} ({n})"); failures += 1
    # D6.2 seeding inference FAILED (no 2xx) + sentinel miss -> UNK, not SECURE.
    d62_down = ("# D6.2\n# --- raw response (headers + body) ---\n"
                "curl: (56) Recv failure: Connection reset by peer\n"
                "# --- meta ---\n# curl_exit: 56\n"
                "# --- grep ---\nPROMPT_FOUND_IN_LOGS=0\n")
    tmp.write_text(d62_down, encoding="utf-8")
    s, c, _, n = score("D6.2", tmp)
    if s != "UNK":
        print(f"selftest FAIL: D6.2 seeding-failed -> {s}/{c} ({n})"); failures += 1
    # D6.2 seeding 404 (malformed payload) + miss -> UNK, not SECURE.
    d62_404 = ("# D6.2\n# --- raw response (headers + body) ---\n"
               "HTTP/1.1 404 Not Found\n\nbody\n"
               "# --- meta ---\n# curl_exit: 0\n"
               "PROMPT_FOUND_IN_LOGS=0\n")
    tmp.write_text(d62_404, encoding="utf-8")
    s, c, _, n = score("D6.2", tmp)
    if s != "UNK":
        print(f"selftest FAIL: D6.2 seeding-404 -> {s}/{c} ({n})"); failures += 1
    # D6.2 seeding 200 + sentinel miss -> SECURE.
    d62_ok = ("# D6.2\n# --- raw response (headers + body) ---\n"
              "HTTP/1.1 200 OK\n\n{\"ok\":true}\n"
              "# --- meta ---\n# curl_exit: 0\n"
              "PROMPT_FOUND_IN_LOGS=0\n")
    tmp.write_text(d62_ok, encoding="utf-8")
    s, c, _, n = score("D6.2", tmp)
    if (s, c) != ("SECURE", "HIGH"):
        print(f"selftest FAIL: D6.2 seeding-ok-miss -> {s}/{c} ({n})"); failures += 1
    # D6.2 sentinel HIT -> INSECURE regardless of status.
    d62_hit = ("# D6.2\n# --- raw response (headers + body) ---\n"
               "HTTP/1.1 200 OK\n\nx\n# --- meta ---\n# curl_exit: 0\n"
               "PROMPT_FOUND_IN_LOGS=1\n/root/.ollama/logs/server.log\n")
    tmp.write_text(d62_hit, encoding="utf-8")
    s, c, _, n = score("D6.2", tmp)
    if (s, c) != ("INSECURE", "HIGH"):
        print(f"selftest FAIL: D6.2 sentinel-hit -> {s}/{c} ({n})"); failures += 1
    tmp.unlink(missing_ok=True)
    if failures == 0:
        print("score_item.py selftest OK"); return 0
    return 1

def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--item")
    ap.add_argument("--transcript")
    args = ap.parse_args(argv)
    if args.selftest:
        return selftest()
    if not args.item or not args.transcript:
        ap.error("need --item and --transcript (or --selftest)")
    s, c, ev, n = score(args.item, Path(args.transcript))
    print(f"{args.item},{s},{c},{ev},\"{n}\"")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
