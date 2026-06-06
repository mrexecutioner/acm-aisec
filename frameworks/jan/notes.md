# Jan - notes

## DROPPED from the measured set (v2, 2026-05-30)
Jan is **out of scope** as of the v2 run. Rationale: it is a desktop GUI
application (Electron) targeting single-user local use, not headless deployable
serving infrastructure, so it falls outside this study's threat model and cannot
be driven by the headless harness. The v2 measured set is the 7 headless/
deployable frameworks (ollama, vllm, llamacpp, localai, tgwui, sglang, tgi). The
llama.cpp engine that underlies Jan is still represented, measured as a deployed
server. See analysis/INSTRUMENT_NOTES.md (ARTIFACT-5). Retained here for
provenance; not installed/probed/scored in v2.


## Source
- Docs: https://jan.ai/docs
- API: https://jan.ai/api-reference
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Why not batch-scoreable
- Jan is a desktop application (Electron). No container image; server mode is started from the app UI.
- Per PROTOCOL.md hard constraint #4, all items are UNK in this batch. Human scores from a VM snapshot pass.

## Documented defaults (for matrix entry note)
- Server port: 1337.
- Default bind: 127.0.0.1.
- API key: none by default; opt-in.
