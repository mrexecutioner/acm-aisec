# localai, v8 doc-honesty evidence (official docs only)
Source: localai.io/basics/getting_started/ (checked 2026-06-02)

- D7.1: [SECURE] getting-started 'Security considerations' tip warns 'protect the API endpoints adequately' and shows LOCALAI_API_KEY hardening on the quickstart page itself
- D1.2: [SECURE] 'Security considerations' tip explicitly warns about remote exposure and to protect endpoints
- D2.2: [WARNS] native LOCALAI_API_KEY (+ LOCALAI_AUTH) exist but OFF by default

## PLACEMENT CONFIRMATION (2026-06-02)
The "Security considerations" tip is INLINE on the getting-started page, near the
top, BEFORE the "Starting LocalAI" instructions, a sequential quickstart reader
encounters it before launching. Bar for SECURE is met (operator would actually
see the warning + hardening in the normal flow). SECURE upheld for D7.1/D1.2.
