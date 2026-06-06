# Ollama - notes

## Source
- Official Docker quickstart: https://github.com/ollama/ollama/blob/main/docs/docker.md
- README: https://github.com/ollama/ollama
- API spec: https://github.com/ollama/ollama/blob/main/docs/api.md
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: container listens on 0.0.0.0:11434 inside the network namespace; published as 0.0.0.0:11434 on host by `-p 11434:11434`.
- Auth: none by default. No native API key mechanism in core; recent versions add `OLLAMA_AUTH` env but it is **off by default**.
- Mgmt endpoints (`/api/pull`, `/api/delete`, `/api/create`) ungated by default.
- Telemetry: minimal (update check by default, note this for D6.1).
- Container User: official image uses root (`USER` unset).

## Likely findings (anticipated, not scored)
- D2.1, D3.1, D3.2, D3.4 → INSECURE (clean 200s with no auth).
- D5.3 → INSECURE (runs as root by default).
- D2.2 → WARNS (no native auth in stable; punted to reverse proxy historically).

## Items requiring human read
- D5.1, tool/template execution boundaries in Ollama chat.
- D6.1, update-check egress; document the destination if observed.
- D7.1, does the quickstart show a secure setup? (Subjective.)

## Install reproducibility
- `image: ollama/ollama:latest` is **not pinned** in `compose.yml` because the docs themselves do not pin a digest in the quickstart. The install script records `docker inspect` so the digest used in the run is captured in `runs/ollama/config_snapshot/inspect.json`.
- This is a deliberate fidelity-vs-reproducibility tradeoff. Flagged for human review of methodology.
