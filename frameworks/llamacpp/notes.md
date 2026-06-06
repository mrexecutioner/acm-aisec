# llama.cpp (llama-server) - notes

## Source
- Server docs: https://github.com/ggerganov/llama.cpp/blob/master/examples/server/README.md
- Docker docs: https://github.com/ggerganov/llama.cpp/blob/master/docs/docker.md
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: `--host 127.0.0.1` is the **server binary's** default. Quickstart docs commonly pass `--host 0.0.0.0` for Docker. D1.1 distinguishes between binary default and quickstart default.
- Auth: optional `--api-key` flag; **none by default**.
- No model push/pull/delete management API.

## Items requiring human read
- D1.1, note the binary-vs-quickstart bind difference in scoring.
- D1.2, docs do warn about LAN exposure (recent versions). Read carefully.
- D5.1, grammar / tool-use surface.
