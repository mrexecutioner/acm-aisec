# llamacpp, v8 doc-honesty evidence (official docs only)
Source: github.com/ggml-org/llama.cpp tools/server/README.md (checked 2026-06-02)

- D7.1: [INSECURE] llama-server README: no security warning; docker example uses --host 0.0.0.0 with no caveat
- D1.2: [INSECURE] --host 0.0.0.0 docker example, no exposure caveat
- D2.2: [WARNS] native --api-key exists (default: none/off)

## v8 AUDIT, separate security page? YES -> UPLIFT
SECURITY.md (github.com/ggml-org/llama.cpp, section "Untrusted environments or
networks") warns operators "Do not use ... llama-server" in untrusted/networked
environments. A separate official page warning about exposing the MEASURED server
(same standard as vLLM) -> D7.1/D1.2 uplifted INSECURE -> WARNS.
