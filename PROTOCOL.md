# Measurement protocol

This file documents the measurement methodology and the integrity constraints
the study held itself to. It is the reference for the "see PROTOCOL.md" pointers
in the harness and notes.

## What is measured

The **default security posture** of self-hosted LLM serving frameworks: what a
fresh, documentation-following install exposes on the local host, *before* any
operator hardening. Each (framework, item) cell is scored on an 18-item checklist
across seven dimensions.

### Checklist (D1–D7)

- **D1 Network exposure**, D1.1 default bind address · D1.2 documentation's exposure guidance
- **D2 Auth/authz**, D2.1 auth required by default · D2.2 native auth exists but ships disabled · D2.3 admin vs inference gated differently
- **D3 Management endpoints (unauth)**, D3.1 list · D3.2 pull/load · D3.3 push/export · D3.4 delete/mutate
- **D4 Resource abuse**, D4.1 unauthenticated inference · D4.2 default rate limiting
- **D5 Code/file surface**, D5.1 template/tool exec · D5.2 arbitrary file read via path traversal · D5.3 runs as root / privileged container
- **D6 Data & telemetry**, D6.1 telemetry on by default · D6.2 prompt/response disk logging
- **D7 Documentation honesty**, D7.1 quickstart warns about insecure defaults · D7.2 gap score (# of D1–D6 insecure-by-default *despite* a documented secure option)

## Scoring rubric

Each cell receives one of `INSECURE` / `SECURE` / `WARNS` / `N_A` / `UNK`, plus a
`HIGH` / `LOW` confidence flag.

- `N_A` is a concrete result, no such attack surface exists by default
  (e.g. no push endpoint), confirmed against a live route listing or documented API.
- `UNK` records the absence of decisive evidence and is **distinct** from `N_A`.
- **Absence of evidence is never scored `SECURE`.** A cell is `SECURE` only when a
  probe positively demonstrates the secure behavior.
- `HIGH` confidence requires an unambiguous transcript; ambiguity, guessed endpoint
  paths, nondeterminism, or subjective judgment force `LOW`.

## Integrity constraints

1. **Local only.** Every probe targets the loopback interface of the test host
   (`127.0.0.1` / `::1` / `localhost`). The harness refuses non-loopback
   destinations by construction. No third-party host is ever probed.
2. **No invented results.** Every score is backed by a saved transcript on disk
   (`evidence_file` column of the matrix). If evidence cannot be produced, the
   score is `UNK`, never a guess.
3. **Deterministic & reproducible.** Each framework is pinned to a fixed container
   image digest (see `README.md`). Probes are runnable from the `Makefile`.
4. **Honest self-flagging.** Every `LOW`-confidence and `UNK` cell is listed in the
   review queues (`analysis/REVIEW_QUEUE*.md`) with what is ambiguous and what a
   reviewer should check. Uncertainty is surfaced, never smoothed over.
5. **Double-blind hygiene.** No author, institution, or machine identity appears in
   the harness, transcripts, or notes.
