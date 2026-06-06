# ollama, v8 doc-honesty evidence (official docs only)
Source: docs.ollama.com/faq (checked 2026-06-02)

- D7.1: [INSECURE] FAQ gives OLLAMA_HOST config with no security caveat, no auth mention
- D1.2: [INSECURE] instructs OLLAMA_HOST=0.0.0.0 to expose with no exposure-risk warning
- D2.2: [WARNS] NO native auth; FAQ points only to reverse proxy (Nginx)/tunnels

## v8 AUDIT, separate security page? NO -> INSECURE stands
docs.ollama.com/api/authentication is about ollama.com CLOUD auth; it states "No
authentication is required when accessing Ollama's API locally" with NO hardening
guidance. SECURITY.md is a vuln-disclosure policy. No separate page warns about
securing the local server. INSECURE verified.
