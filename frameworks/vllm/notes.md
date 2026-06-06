# vLLM - notes

## Source
- Docker docs: https://docs.vllm.ai/en/latest/serving/deploying_with_docker.html
- OpenAI-compat server: https://docs.vllm.ai/en/latest/serving/openai_compatible_server.html
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: 0.0.0.0:8000 by default.
- Auth: none by default. `--api-key` flag is opt-in.
- Mgmt: no push/pull/delete in core server (model is specified at launch).
- Container User: official image runs as root.

## Platform caveat
- Requires NVIDIA CUDA. **On this Windows host without verified GPU+nvidia-docker, vLLM will not start.** Probes will produce UNK rows. This is recorded in the SUMMARY's "NEEDS HUMAN REVIEW" section by the scorer.

## Items requiring human read
- D5.1, tool-call / template surface in OpenAI-compat mode.
- D6.1, telemetry (vLLM has metrics endpoint but no known external phone-home).
- D7.1, does the quickstart show a secure setup?
