# Review Queue, v7 (PART A done; PART B pending)

## Evidence-based conversions (HIGH), spot-check
- D1.1 all 7 INSECURE/HIGH: in-container /proc/net/tcp shows 0.0.0.0/:: listener (runs_v7/<fw>/probes/D1.1.txt).
- D3.2 tgwui INSECURE/HIGH (unauth model-load; cross-ref runs_v6 Job3 200-unauth), vllm/llamacpp/tgi N/A (no pull endpoint).

## Flagged LOW, need human verification
- D1.2 / D2.2 / D7.1 (all 7): informed priors from background knowledge, NOT live-verified, PROTOCOL.md constraint #1 precluded fetching third-party docs. HUMAN: verify against live docs (URLs in each note) or authorize a doc-fetch follow-up.
- D3.2 sglang INSECURE/LOW: endpoint reachable unauth (HTTP 400 on bad path = no 401); successful unauth weight-load not confirmed.
- D7.2 (all 7): gap score computed from D1-D6 INSECURE counts (ollama/vllm/sglang 8, localai 9, llamacpp/tgi 7, tgwui 6).

## PART B results
- D5.1 all 7: SECURE/LOW, benign template-injection NOT evaluated server-side (time-boxed; request-vector only). HUMAN: deeper templating fuzz out of scope.
- D6.1 sglang: SECURE/HIGH (log-confirmed HF model fetch, metrics off). tgi: INSECURE/LOW (usage_stats=On default telemetry, CONFIRM payload). tgwui + localai: HONEST UNK (TLS-opaque external contact, purpose unconfirmed).
- B3 tgwui default D2.1/D4.1: re-confirmed no-model -> left UNK (correct).
