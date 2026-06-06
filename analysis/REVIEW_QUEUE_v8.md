# Review Queue, v8 (doc-honesty verification: D7.1, D1.2, D2.2)

All 21 doc cells are now HIGH-confidence, each backed by an official-doc citation in
findings_v8/<fw>/doc_evidence.md. 4 score changes overturned v7 priors:

| framework | item | v7 prior | v8 verified | note |
|---|---|---|---|---|
| localai | D7.1 | INSECURE/LOW | **SECURE/HIGH** | getting-started warns + shows LOCALAI_API_KEY (only fw that warns on its quickstart) |
| localai | D1.2 | INSECURE/LOW | **SECURE/HIGH** | "Security considerations" tip warns about remote exposure |
| vllm | D7.1 | INSECURE/LOW | **WARNS/HIGH** | dedicated security page warns, but separate from the serving quickstart |
| vllm | D1.2 | INSECURE/LOW | **WARNS/HIGH** | security page warns all-interface bind + firewall guidance |

Correction (score unchanged, finding fixed):
- tgi D2.2 WARNS, v7 prior wrongly said "no native auth"; launcher reference confirms **--api-key (env API_KEY) DOES exist** (off by default). Also confirmed --usage-stats default=on (supports the v6/v7 D6.1 telemetry finding; D6.1 not re-scored here).

Spot-check (newly HIGH, with citation in findings_v8/<fw>/doc_evidence.md):
- D7.1: 5 INSECURE (ollama, llamacpp, tgwui, sglang, tgi), 1 WARNS (vllm), 1 SECURE (localai).
- D1.2: same split.
- D2.2: 7 WARNS, native auth exists-but-OFF for 6 (vllm/llamacpp/localai/tgwui/sglang/tgi); ollama has NO native auth (proxy-only).
- D7.2 recomputed: vllm 8->7, localai 9->8 (D1.2 changes); tgi 7->8 (v8 stale-fix, v7 gap predated its Part-B D6.1 INSECURE).

## v8 AUDIT addendum, separate-security-page parity check (uniform vLLM standard)
Audited the 5 still-INSECURE frameworks for a separate official security/deployment
page (off the quickstart) that warns about the MEASURED server's insecure defaults:
- llamacpp -> UPLIFT to WARNS: SECURITY.md warns "do not expose llama-server to untrusted networks".
- ollama -> INSECURE stands: /api/authentication is cloud-auth; no local-server hardening warning.
- sglang -> INSECURE stands: only the optional Model Gateway/Router doc has security guidance; not the core server.
- tgwui -> INSECURE stands (doc-honesty): docs don't warn (a RUNTIME --listen warning exists, non-doc, noted).
- tgi -> INSECURE stands: no separate security page; quicktour/launcher don't warn.
Net: 1 uplift (llamacpp D7.1/D1.2 INSECURE->WARNS; D7.2 gap 7->6). Others verified INSECURE.
