# sglang, v8 doc-honesty evidence (official docs only)
Source: docs.sglang.io/advanced_features/server_arguments.html (checked 2026-06-02)

- D7.1: [INSECURE] server-arguments page is a pure reference; no security warning; example binds 0.0.0.0 w/o caveat
- D1.2: [INSECURE] code default --host=127.0.0.1 (loopback) but docs/example bind 0.0.0.0 with no exposure caveat
- D2.2: [WARNS] native --api-key (+ --admin-api-key) exists, default None/off

## v8 AUDIT, separate security page? NOT FOR THE MEASURED SERVER -> INSECURE stands
The only SGLang security doc (Model Gateway/Router) concerns the OPTIONAL gateway
component, "not part of the core SGLang server", and "frames these as production
recommendations rather than warnings about insecure defaults". It does not warn
about the core sglang.launch_server we measured. INSECURE verified.
