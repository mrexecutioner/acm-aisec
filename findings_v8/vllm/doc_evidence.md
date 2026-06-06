# vllm, v8 doc-honesty evidence (official docs only)
Source: docs.vllm.ai/en/latest/usage/security.html (checked 2026-06-02)

- D7.1: [WARNS] dedicated Security page warns 'insecure by default' + isolated-network/firewall + --api-key caveat, but the serving quickstart itself does not warn (separate page)
- D1.2: [WARNS] Security page warns all-interface binding (TCPStore) is insecure by default + recommends firewall/isolated network
- D2.2: [WARNS] native --api-key / VLLM_API_KEY exists but OFF by default; docs caution it protects only /v1, other endpoints stay unauth

## PLACEMENT CONFIRMATION (2026-06-02)
The vLLM quickstart page does NOT warn about insecure defaults and does NOT link
to the security page; the warnings ("insecure by default", firewall/isolated
network) live on a SEPARATE /usage/security page off the getting-started flow ->
WARNS (not SECURE: off-path; not INSECURE: a real warning exists in official docs).
The quickstart mentions --api-key/VLLM_API_KEY only as an option (supports D2.2),
not as a security warning.
