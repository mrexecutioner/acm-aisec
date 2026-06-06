# Text-Generation-WebUI (oobabooga) - notes

## Source
- Repo: https://github.com/oobabooga/text-generation-webui
- Docker wiki: https://github.com/oobabooga/text-generation-webui/wiki/09-%E2%80%90-Docker
- API wiki: https://github.com/oobabooga/text-generation-webui/wiki/12-%E2%80%90-OpenAI-API
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: 127.0.0.1 unless `--listen` is passed. Docker quickstart commonly passes `--listen`. This is a real default-vs-quickstart gap (D1.1 / D1.2).
- API: off unless `--api` is passed. With --api, OpenAI-compat at :5000.
- Auth: optional `--api-key`; none by default.

## Items requiring human read
- D1.1, D1.2, binary default vs documented Docker default.
- D5.1, TGWUI exposes Python eval surfaces in some extensions; in-base API does not.
- D7.1, Docker quickstart explicitly opts into LAN exposure - subjective scoring.

## v6 Job 3, model-loaded inference-auth (NON-DEFAULT, 2026-06-01)
tgwui ships NO model by default, so default-state inference-auth is unobservable
(D2.1/D4.1 = UNK, HTTP 500). To reveal the auth behavior (independent of whether a
model is present), a model was loaded via tgwui's own documented API, this is an
explicitly NON-DEFAULT configuration and does NOT change tgwui's default-state cells:
  1. staged a tiny GGUF: `docker cp <TinyLlama-1.1B-Q4_K_M>.gguf secdefaults-tgwui:/app/user_data/models/tinyllama.gguf`
  2. loaded it: `POST /v1/internal/model/load {"model_name":"tinyllama.gguf"}` -> "OK"
  3. confirmed `/v1/models` lists `tinyllama.gguf` and `/v1/chat/completions` returns 200.
  4. re-probed D2.1/D4.1 with NO auth header -> HTTP 200 (served).
Result: **INSECURE when a model is loaded (non-default)**, serves inference without
authentication, consistent with its unauthenticated /v1/models (D3.1). Recorded as
runs_v6/tgwui/probes/D2.1_modelloaded.txt / D4.1_modelloaded.txt and as separate
annotated matrix rows (D2.1_modelloaded / D4.1_modelloaded, source_run=v6). The
default-state D2.1/D4.1 cells remain UNK and were NOT overwritten.
