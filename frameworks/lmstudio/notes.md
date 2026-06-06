# LM Studio - notes

## DROPPED from the measured set (v2, 2026-05-30)
LM Studio is **out of scope** as of the v2 run. Rationale: it is a desktop GUI
application (Electron) targeting single-user local use, not headless deployable
serving infrastructure, so it falls outside this study's threat model and cannot
be driven by the headless harness. The v2 measured set is the 7 headless/
deployable frameworks (ollama, vllm, llamacpp, localai, tgwui, sglang, tgi). The
llama.cpp engine that underlies LM Studio is still represented, measured as a
deployed server. See analysis/INSTRUMENT_NOTES.md (ARTIFACT-5). Retained here for
provenance; not installed/probed/scored in v2.


## Source
- Docs: https://lmstudio.ai/docs
- CLI (`lms`): https://lmstudio.ai/docs/cli
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Why not batch-scoreable
- LM Studio is a desktop application (Electron). It does not ship a container image and the server is started via the GUI Developer tab or the `lms server start` CLI on a host install.
- Per PROTOCOL.md hard constraint #4, this framework's items will all be UNK in this batch and **must be scored from a VM snapshot run by the human**.

## Documented defaults (for the matrix entry note)
- Server port: 1234.
- Default bind: 127.0.0.1 (per LM Studio docs); LAN serve is opt-in.
- Auth: none by default; "Just-In-Time Model Loading" can be toggled.
