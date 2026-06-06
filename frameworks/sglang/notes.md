# SGLang - notes

## Source
- Docs: https://docs.sglang.ai
- Server quickstart: https://docs.sglang.ai/start/install.html
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: `--host 0.0.0.0` per quickstart. Server-binary default is 127.0.0.1.
- Auth: optional `--api-key`; none by default.
- Admin endpoints (`/update_weights_from_disk`, `/flush_cache`) ungated by default.

## Platform caveat
- Requires NVIDIA CUDA. Will not start on this Windows host without verified GPU. Probes will UNK.

## Items requiring human read
- D5.1, code/template execution via SGLang's runtime API (well beyond OpenAI surface).
- D5.2, `/update_weights_from_disk` could be a path-traversal vector.
