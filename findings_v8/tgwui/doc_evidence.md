# tgwui, v8 doc-honesty evidence (official docs only)
Source: github.com/oobabooga/text-generation-webui README.md (checked 2026-06-02)

- D7.1: [INSECURE] README documents --listen ('reachable from local network') with no security caveat
- D1.2: [INSECURE] --listen documented as 'reachable from local network', no caveat
- D2.2: [WARNS] native --api-key/--admin-key (API) + --gradio-auth (UI) exist but OFF by default

## v8 AUDIT, separate security DOC page? NO -> INSECURE stands
The OpenAI-API wiki documents --api-key only as an option, no cautionary text;
the README's --listen has no caveat. NB: the app emits a RUNTIME warning at
--listen ("potentially exposing the web UI to the entire internet without any
access password"), a mitigating factor, but NOT documentation, so it does not
change the doc-honesty (D7.1) score. INSECURE verified (docs do not warn).
