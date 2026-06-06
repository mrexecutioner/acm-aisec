# tgi, v8 doc-honesty evidence (official docs only)
Source: huggingface.co/docs/text-generation-inference quicktour + reference/launcher (checked 2026-06-02)

- D7.1: [INSECURE] quicktour: bare 'docker run -p 8080:80 --model-id', no security/auth/telemetry caveat
- D1.2: [INSECURE] quicktour -p 8080:80 publishes the port; --hostname default 0.0.0.0; no exposure caveat
- D2.2: [WARNS] native --api-key (env API_KEY) EXISTS but OFF by default [CORRECTION: v7 prior wrongly said 'no native auth']

## v8 AUDIT, separate security page? NO -> INSECURE stands
No separate official security/hardening page found (only cloud-platform deployment
guides). Quicktour and launcher reference do not warn about insecure defaults.
INSECURE verified.
