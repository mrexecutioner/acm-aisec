# Review Queue, v9 (Group-1: D2.3, D3.3, D3.4, 20 cells resolved)

UNK 26 -> 6. Of the 20 in-scope cells: 4 INSECURE, 1 WARNS, 15 N/A, 0 left UNK.

## NEW INSECURE/HIGH, spot-check (each has a probe transcript)
| framework | item | finding | transcript |
|---|---|---|---|
| ollama | D3.3 | unauth POST /api/push (200, executed push workflow) | runs_v9/ollama/probes/D3.3.txt |
| localai | D3.4 | unauth POST /models/delete/{name} (200, accepted as job) | runs_v9/localai/probes/D3.4.txt |
| tgwui | D3.4 | unauth POST /v1/internal/model/unload (200 "OK") | runs_v9/tgwui/probes/D3.4.txt |
| sglang | D3.4 | unauth POST /flush_cache (200 "Cache flushed") | runs_v9/sglang/probes/D3.4.txt |

## Judgment call, please verify
- sglang D2.3 = WARNS/LOW: /hicache/storage-backend refuses without --admin-api-key (400) while /flush_cache + inference are open (200) → a per-endpoint authz tier exists but is incomplete. Borderline N/A-vs-WARNS; transcript: runs_v9/sglang/probes/D3.4.txt.

## N/A (endpoint absent), evidence basis
- D3.3 N/A ×6: vllm/sglang/tgwui via live OpenAPI route list (no push); localai/tgi/llamacpp via documented API (no live OpenAPI dump, documented-API basis, noted).
- D3.4 N/A ×3: vllm (OpenAPI, no delete/unload); llamacpp (slots-mutate 501-disabled by default); tgi (documented API, no delete).
- D2.3 N/A ×6: uniform no-auth default (no endpoint enforces a key), no per-endpoint authz to evaluate.

## Out-of-scope UNK (left untouched, confirmed)
ollama D4.1, localai D6.1, tgwui D2.1, tgwui D4.1, tgwui D6.1, tgwui D6.2, these 6 have no honest non-UNK answer (no default model / cold-load nondeterminism / TLS-opaque CDN contact).

## STALE (flagged, NOT touched per v9 scope)
D7.2 gap scores are now STALE: v9 added new D3.3/D3.4 INSECUREs (ollama D3.3; localai/tgwui/sglang D3.4) that the D7.2 gap counts do NOT reflect. v9 scope was "touch ONLY D2.3/D3.3/D3.4", so D7.2 was left unchanged. Recompute in a follow-up: ollama 8->9, localai 8->9, tgwui 6->7, sglang 8->9.
