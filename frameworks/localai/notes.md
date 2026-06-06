# LocalAI - notes

## Source
- Getting started: https://localai.io/basics/getting_started/
- API reference: https://localai.io/docs/reference/
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: 0.0.0.0:8080.
- Auth: API key opt-in via `API_KEY` env; **off by default**.
- Mgmt: `/models/apply` accepts gallery pulls without auth by default.

## Items requiring human read
- D5.1, function/tool calling surface.
- D6.1, LocalAI does not document phone-home; verify via tcpdump in D6.1 transcript.
