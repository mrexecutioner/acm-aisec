# Instrument notes / known harness artifacts (for the human verification pass)

Issues found DURING the batch run (2026-05-30) and what was done about them.
Read this BEFORE trusting analysis/matrix.csv. Scores were regenerated from the
saved raw transcripts after the scorer fixes below, no framework was re-installed
or re-probed, so every score still maps to a real transcript on disk.

--------------------------------------------------------------------------------
## TL;DR for the human
- The harness ran all 9 frameworks end-to-end and the scoring logic is now
  correct (3 scorer bugs found + fixed, with regression self-tests added).
- BUT real measurement coverage is LOW: only **ollama** came up fully; **tgwui**
  came up partially; the other 7 servers were DOWN at probe time (heavy model
  load exceeded the health-check window, missing model file, or desktop-only
  app). So most D2/D3/D4 HTTP cells are honestly UNK. The matrix is correct but
  thin, a re-run with proper readiness gating is needed for a publishable matrix
  (see ARTIFACT-4).
- Net confident findings this run: ollama (unauth list/pull/inference + no rate
  limiting + root container) and tgwui (unauth list-models + no rate limiting +
  root container); root-container (D5.3) for vllm/sglang/tgi as well.

--------------------------------------------------------------------------------
## ARTIFACT-1, D2.1 cold-start false-UNK (FIXED note only; score unchanged) [LOW severity]
**Symptom:** D2.1 (auth-for-inference) timed out (curl exit 28) on ollama because
the first inference call triggers a cold model load > the 8 s curl timeout; the
identical probe D4.1, run ~10 s later against the now-warm model, returned 200.
**Status:** The auto-note used to say "service likely not running" (false). Note
text fixed to distinguish exit 28 (timeout / possible cold load, cross-check
D4.1) from exit 7/56 (connection refused/reset, server down). The SCORE stays
UNK/LOW (the safe call); ollama's true unauth-inference posture is captured by
D4.1 = INSECURE/HIGH. **v2 fix:** add a discarded warm-up inference before the
scored inference probes, or raise the inference-probe timeout to ~60 s.

## ARTIFACT-2, D4.2 fabricated INSECURE/HIGH on dead servers (FIXED) [HIGH severity]
**Symptom:** 6 frameworks whose servers never came up were scored
INSECURE/HIGH "0/200 requests throttled", a fabricated HIGH-confidence finding,
violating PROTOCOL.md constraint 2 (NO INVENTED RESULTS).
**Root cause:** the burst probe (harness/probes/D4.2.sh) emits a synthetic
`HTTP/1.1 000 curl_error_<n>` line per failed request; the scorer's regex
`HTTP/[\d.]+\s+\d{3}` matched `000`, so 100 dead requests read as "200 served, 0
throttled → INSECURE". (Each iteration emits two `000` lines, hence "0/200".)
**Fix (harness/lib/score_item.py score_D4_2):** count only genuine `[1-5]\d{2}`
statuses, require a real 2xx baseline (≥10) before concluding "unthrottled →
INSECURE", and return UNK when the server served nothing. Regression self-tests
added (server-down→UNK, served-unthrottled→INSECURE, throttled→SECURE).
**Effect:** D4.2 INSECURE/HIGH now only for ollama and tgwui (both genuinely
served 100× HTTP 200, 0 throttled, verified). The other 6 → UNK.

## ARTIFACT-3, D6.2 false SECURE/HIGH (seeding inference never ran) (FIXED) [MED severity]
**Symptom:** D6.2 (prompt disk-logging) scored SECURE/HIGH for 7 frameworks
("no plaintext prompt in log dir"), but the sentinel was never actually logged
because the seeding inference call never succeeded on ANY framework.
**Root cause (two layers):** (a) on down servers the seeding call got a
connection error; (b) even on ollama it got HTTP 404 because the probe's fallback
body `{"prompt":...}` omits the required `model` field, the probe only injects
the sentinel into the real endpoints.yml payload if that payload contains a
`{PROMPT}` placeholder, which none do. So "sentinel not found" was trivially true
everywhere and meant nothing.
**Fix (score_D6_2):** a sentinel HIT is still INSECURE; a MISS only scores SECURE
if the embedded seeding call returned 2xx, else UNK ("logging surface never
exercised"). Regression self-tests added.
**Effect:** all D6.2 → UNK this run (no framework validly exercised logging).
**v2 fix:** give the D6.2 probe a per-framework correct inference payload (with
`model` field) so the sentinel actually gets processed; add a `{PROMPT}`
placeholder to each endpoints.yml inference_payload.

## ARTIFACT-4, Low coverage: most servers were DOWN at probe time [process, not a bug]
Why each framework's HTTP probes are mostly UNK:
- **vllm / sglang / tgi:** heavy HF model download/load exceeded the install
  health-check window (120s/60s); containers were up but not serving when probes
  ran. → raise readiness wait / pre-stage weights, then re-probe.
- **llamacpp:** no `.gguf` model file under `frameworks/llamacpp/models`, so
  llama-server could not start. → stage a small gguf, re-run.
- **lmstudio / jan:** desktop-only GUI apps; cannot run headless in a container
  (install.sh exits with that message). → per playbook, snapshot a VM. Their
  D5.3 "no User field" is expected (no container).
- **localai:** not healthy after 120s. → investigate boot, raise wait, re-probe.
Only **ollama** produced a complete clean posture; **tgwui** partial (list-models
+ burst endpoint served 200 even though the readiness endpoint reported unhealthy
, worth a human look at why).

--------------------------------------------------------------------------------
## What is trustworthy in this run
- All INSECURE/HIGH rows (11) are backed by real 2xx/῾docker inspect transcripts:
  ollama D3.1/D3.2/D4.1/D4.2/D5.3, tgwui D3.1/D4.2/D5.3, vllm/sglang/tgi D5.3.
- All UNK rows have an honest reason (server down, subjective/doc-derived, or
  probe-not-exercised). None are guesses.
- The 3 scorer fixes are covered by `make harness` self-tests.

================================================================================
# v2 MEASUREMENT RUN (2026-05-30)

v2 fixes the v1 *coverage* problems (ARTIFACT-4) WITHOUT touching scoring logic
(the v1 scorer fixes stand). Outputs go to separate paths so v1 is never
overwritten: `runs_v2/<fw>/`, `findings_v2/<fw>/SUMMARY.md`,
`analysis/matrix_v2.csv`, `analysis/REVIEW_QUEUE_v2.md`. Entry point: `make batch-v2`.

## ARTIFACT-5, Scope narrowed to headless/deployable frameworks
Dropped **lmstudio** and **jan** from the measured set. Rationale: both are
desktop GUI applications (Electron) targeting single-user local use, not headless
deployable serving infrastructure, outside this study's threat model and not
drivable by the headless harness (in v1 they produced only honest-but-empty UNK
rows / install-failed). The llama.cpp engine underlying both remains in scope,
measured as a deployed server. v2 measured set (7): ollama, vllm, llamacpp,
localai, tgwui, sglang, tgi. Recorded in frameworks/{lmstudio,jan}/notes.md and
the Makefile FRAMEWORKS list.

## Readiness gating (fixes ARTIFACT-4 timing artifact)
v1 fired probes on a fixed timer while servers were still loading weights. v2
adds `harness/lib/wait_ready.sh` + a `make wait` step between install and probe:
it polls each framework's readiness endpoint (new `readiness:` key in
endpoints.yml) until it returns 2xx, ceiling **900s (15 min)** for heavy GPU
loads. Time-to-ready is recorded per framework in `runs_v2/<fw>/ready.txt` and
echoed to the batch log (distinguishes "slow boot" from "won't boot"). If
readiness never returns 2xx within the ceiling it is a TRUE startup failure →
dependent items UNK (a real negative, not a timing artifact).
Readiness endpoints: ollama /api/tags · vllm /health · llamacpp /health ·
localai /readyz · tgwui /v1/models · sglang /health · tgi /health.

## Model pre-staging (separate load time from posture)
- **llamacpp:** install.sh pre-downloads a pinned tiny GGUF
  (TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF, Q4_K_M, ~669MB) to the mounted models
  dir as model.gguf BEFORE container start (v1 had no model file).
- **sglang:** swapped HF-gated meta-llama/Llama-3.2-1B-Instruct (could not
  download without a token, a hidden v1 failure cause) for ungated
  **Qwen/Qwen2.5-0.5B-Instruct**.
- **ollama:** tinyllama pulled (blocking) in install.sh before probing.
- **vllm** facebook/opt-125m · **tgi** gpt2 · **localai** aio-cpu bundled models ,
  download/prepare on boot, covered by the 15-min readiness ceiling.
All models are tiny inference substrate to make endpoints live, NOT objects of
study. GPU frameworks (vllm/sglang/tgi) still require CUDA; if the RTX 5090
(Blackwell) is unsupported by an image, that is an honest FAILED-to-start → UNK.

## End-of-run report blind spot (FIXED, item #5)
v1's report counted "high-impact" as INSECURE+LOW only, which structurally could
NOT surface a fabricated INSECURE+HIGH (the exact v1 D4.2 bug). The report now
ALSO lists EVERY HIGH-confidence INSECURE row for human spot-check.

## Still-open limitation (out of v2 scope by instruction)
D6.2 (prompt disk-logging) remains likely-UNK: the probe's sentinel-seeding body
only injects the sentinel when endpoints.yml inference_payload contains a
`{PROMPT}` placeholder, else it falls back to a model-less `{"prompt":...}` body.
Fixing this needs a probe change (a dedicated seeding payload per framework),
which v2 deliberately does NOT make ("same probes"). Deferred to a future probe
revision; D6.2 coverage is not expected to improve in v2.

--------------------------------------------------------------------------------
# v2 RESULTS (2026-05-31)

Matrix: analysis/matrix_v2.csv, 7 frameworks × 18 items = 126 rows.
By score: INSECURE 18 (all HIGH), SECURE 1, N/A 1, UNK 106. By conf: HIGH 20, LOW 106.

## Readiness (time-to-ready, 900s ceiling)
| framework | result | t-to-ready | note |
|-----------|--------|-----------|------|
| ollama   | READY  | 0s   | /api/tags up instantly; tinyllama pre-staged |
| tgwui    | READY  | 5s   | API /v1/models up; no model loaded (default) |
| llamacpp | READY  | 5s   | after image-rename fix (see below) + staged GGUF |
| vllm     | READY  | 196s | opt-125m on GPU, was fully DOWN in v1 |
| sglang   | READY  | 427s | Qwen2.5-0.5B on GPU, was fully DOWN in v1 |
| localai  | FAILED | >903s| genuine slow boot (see below) |
| tgi      | FAILED | >900s| genuine GPU incompatibility (see below) |

5/7 came up (vs ollama-only + tgwui-partial in v1).

## Coverage gain vs v1 (7 common frameworks)
- UNK: 114 (v1) -> 106 (v2). 9 cells moved UNK->real; 1 moved real->UNK
  (ollama D4.1, the cold-load swap below), net -8 UNK.
- New HIGH-confidence findings came from vllm, llamacpp, sglang finally serving:
  D3.1 (unauth list-models), D4.2 (no rate limiting), D5.3 (root container).
- The one SECURE: vllm D5.2 (path traversal -> 404 rejected).

## llamacpp image rename (fixed during v2)
The compose image `ghcr.io/ggerganov/llama.cpp:server` now 404s, the project
moved to `ghcr.io/ggml-org/llama.cpp`. Fixed in compose.yml; llamacpp re-run
became READY in 5s and yielded 3 HIGH-confidence INSECURE (D3.1, D4.2, D5.3).

## tgi, GENUINE failure (GPU kernel incompatibility)
TGI's prebuilt CUDA kernels do not support the RTX 5090 Laptop (Blackwell, sm_120):
logs show `Unkown compute for card nvidia-geforce-rtx-5090-laptop-gpu`, then the
shard crashes during warmup and `restart: unless-stopped` crash-loops it (26+
restarts in 7 min). Never serves. Honest FAILED-to-start. D5.3 (root container) is
still valid from docker-inspect. **Human decision:** try a TGI image tag with
Blackwell support, or report TGI as unmeasurable on this hardware.

## localai, GENUINE failure (aio-cpu multi-GB boot > ceiling)
The `latest-aio-cpu` image downloads several GB of bundled models on first boot
(observed fetching Hermes-3-Llama-3.2-3B 1.9GB at ~16% after 12 min) and does NOT
bind :8080 until done, far exceeds the 15-min ceiling. Not a crash; a heavy
default. **Human decision (out of autonomous scope):** which LocalAI default to
measure, keep aio-cpu and raise its ceiling, OR switch to plain
`localai/localai:latest` + a single tiny pre-staged model that boots fast. I did
NOT change this unilaterally.

## Residual ARTIFACT-1 + a new payload limitation (both out of v2 scope)
- ollama D2.1 vs D4.1 (identical probe) still swap which one is UNK: the 8s curl
  timeout vs cold first-inference is nondeterministic. The pair still captures the
  finding (D2.1=INSECURE here). Unchanged because v2 must not touch probes.
- vllm/sglang D2.1/D4.1 returned HTTP **400** (generic inference payload / model
  name mismatch), which the scorer conservatively records as UNK. The server
  processed the request WITHOUT auth (400, not 401), so the no-auth posture is
  still captured by D3.1, but inference-auth specifically is UNK. Fixing needs
  per-framework inference payloads (a probe change), deferred.

--------------------------------------------------------------------------------
# v3 TARGETED RE-RUN (2026-05-31), localai + tgi only

Per human decision after v2. Outputs in separate paths (runs_v3/, findings_v3/,
matrix_v3.csv, REVIEW_QUEUE_v3.md). The 5 working v2 frameworks and all v1/v2
evidence were NOT touched. matrix_v3.csv holds only localai + tgi (2×18=36 rows).
NOTE: frameworks/localai/* and (no-op) frameworks/tgi/* configs now reflect v3;
the v2 configs are preserved in git commit 2615c4d.

## localai, FIXED (plain image + pre-staged tiny model)
Switched from latest-aio-cpu to plain `localai/localai:latest` + a single
pre-staged TinyLlama-1.1B Q4_K_M GGUF (reused llamacpp's staged file). The plain
image binds its HTTP server / /readyz immediately. Result: **READY in 0s** (vs
FAILED >903s in v2). Coverage UNK 18 -> 11. New findings: D3.1 + D3.2
(unauth model list + unauth /models/apply pull, both 200), D4.2 (no rate
limiting), D5.3 (root container), all HIGH. Plus **D5.2 = INSECURE/LOW**: the
benign path-traversal probe (/models/available family) returned 200 with
file-system-looking content, **flag for human read** (potential unauth path/info
exposure; LOW-confidence, not the severe unauth-RCE class, so no disclosure halt).
D2.1/D4.1 scored N/A (chat endpoint returned 404 for the auto-registered model
name), inference-auth not captured for localai; list/management posture is.

## tgi, UNMEASURABLE on this hardware (one attempt, as directed)
The one attempt was to refresh to the current `:latest`. The registry reports
`:latest` is "up to date", i.e. TGI's published latest is the SAME ~4-month-old
image (no newer stable tag), which lacks RTX 5090 / Blackwell sm_120 kernels
(v2 diag: `Unkown compute for card nvidia-geforce-rtx-5090-laptop-gpu` -> shard
crash-loop). It FAILED readiness again (>900s, conn-refused throughout). Per the
human directive (one attempt, no image surgery), **TGI is recorded as
"unmeasurable on Blackwell hardware (missing CUDA kernel support)."** Only D5.3
(root container, from docker-inspect) is a valid finding; all HTTP items UNK.

## Consolidated study state (authoritative version per framework)
6 of 7 frameworks now have live-server coverage:
- ollama, vllm, llamacpp, tgwui, sglang  -> matrix_v2.csv (READY)
- localai                                 -> matrix_v3.csv (READY)
- tgi                                     -> unmeasurable on Blackwell (matrix_v2/v3: only D5.3)
Robust cross-framework finding: unauth management endpoints (D3.1), no default
rate limiting (D4.2), and root-by-default containers (D5.3) are near-universal.
**analysis/matrix_final.csv is the single authoritative matrix for the paper:**
v2's 5 working frameworks + v3's localai + tgi (unmeasurable). 126 rows; columns
are the standard 6 plus a `source_run` column (runs_v2 / runs_v3) for provenance
(evidence_file paths also encode it). Tally: INSECURE 23 (22 HIGH + 1 LOW =
localai/D5.2), SECURE 1 (vllm/D5.2), N/A 3, UNK 99. The per-version matrices
(matrix.csv v1, matrix_v2.csv, matrix_v3.csv) are retained unchanged.
(NOTE: matrix_final.csv was re-overlaid by v4 below, current tally there.)

--------------------------------------------------------------------------------
# v4 TARGETED RECOVERY (2026-06-01), two scoped jobs

Outputs in runs_v4/, findings_v4/, analysis/matrix_v4.csv, REVIEW_QUEUE_v4.md.
v1/v2/v3 evidence and the 5 working v2 frameworks were not touched except for the
two D2.1/D4.1 cells re-probed per Job 1.

## ARTIFACT-6, probe brace-bug appended a stray '}' to every inference body (FIXED)
Root cause of the v2 vllm/sglang D2.1/D4.1 "400 Extra data" (and likely the
llamacpp 500): the probes built the body as
`BODY="${EP_INFERENCE_PAYLOAD:-{\"prompt\":\"hello\"}}"`. The '}' inside the
`:-{...}` default closes the `${...}` expansion early, so a literal '}' is
appended → body is 62 bytes not 61, ending in `}}`. Strict servers (vllm/sglang
pydantic) reject it as JSON "Extra data"; ollama tolerated it (why its v2 D2.1
passed). Fixed in harness/probes/D2.1.sh and D4.1.sh (assign EP_INFERENCE_PAYLOAD
directly, fall back only if empty). A probe fix (Job 1 = "fix the probe"), NOT a
scoring change.

## Job 1, per-framework inference payloads (vllm, sglang, localai)
Re-probed ONLY D2.1 + D4.1 against freshly-started, readiness-gated servers, model
id taken from each live /v1/models. All three now **INSECURE/HIGH** (200 + output,
no auth):
- **vllm**: payload already correct (`facebook/opt-125m`, /v1/completions); only
  the brace-bug + a cold-load warmup were needed. data_len 61 → 200.
- **sglang**: model id `Qwen/Qwen2.5-0.5B-Instruct`, /v1/chat/completions → 200.
- **localai**: needed real work, the plain image neither auto-registers a bare
  GGUF nor bundles a backend. Added a model-def YAML (name: tinyllama, backend:
  llama-cpp), installed the llama-cpp backend from the gallery, restarted to pick
  it up, and added `max_tokens:8` (CPU tinyllama otherwise streams ~200 tokens and
  exceeds the 8s probe timeout). All baked into
  frameworks/localai/{install.sh,endpoints.yml} for reproducibility.

## Job 2, TGI on CPU (full D1–D7 row)
GPU image is unmeasurable on Blackwell (v2/v3). CPU path:
- `latest-intel-cpu` is BROKEN, mismatched transformers
  (`ModuleNotFoundError: transformers.masking_utils` → ShardCannotStart, crash
  loop). Pinned **`3.0-intel-cpu`**: boots clean on CPU (restarts=0, /health 200;
  the "Torch not compiled with CUDA" warning is expected). Model gpt2.
- Full checklist → **D2.1, D3.1, D4.1, D4.2, D5.3 all INSECURE/HIGH** (vs only
  D5.3 before). frameworks/tgi/{compose.yml,notes.md} updated; notes.md carries the
  docs URL + mixed-environment justification (security defaults are
  hardware-independent, CPU vs GPU changes latency, not auth/network/privilege
  posture) for Threats to Validity.

## matrix_final.csv (authoritative, re-overlaid by v4), 126 rows
`source_run` column gives per-cell provenance: ollama/llamacpp/tgwui = v2 (all 18);
vllm/sglang = v2 except D2.1/D4.1 from v4; localai = v3 except D2.1/D4.1 from v4;
tgi = v4 (full CPU row). Tally: **INSECURE 33, SECURE 1 (vllm/D5.2), N/A 1
(ollama/D3.4), UNK 91; HIGH 34.** v4 recovered 10 cells to INSECURE
(vllm/sglang/localai D2.1+D4.1; tgi D2.1/D3.1/D4.1/D4.2). Cross-framework pattern:
**unauth inference (D2.1/D4.1) INSECURE on ollama, vllm, localai, sglang, tgi**;
unauth management (D3.1), no rate limiting (D4.2), root container (D5.3)
near-universal.

## KNOWN LIMITATION, llamacpp/tgwui D2.1/D4.1 not re-probed (out of v4 scope)
Their matrix_final D2.1/D4.1 cells are v2 values measured with the BUGGY probe
(llamacpp = HTTP 500, tgwui = no-model error → UNK). With the ARTIFACT-6 fix they
would very likely also be INSECURE (both serve unauthenticated). The human chose
not to re-run them; their D2.1/D4.1 UNK is a PROBE ARTIFACT, not evidence that
inference auth is required. Recommend a one-line re-probe of llamacpp + tgwui
D2.1/D4.1 with the fixed probe before publication. (The same latent brace pattern
also remains in D4.2.sh's no-list-models fallback, unexercised here.)
[CLOSED in v5, see below.]

--------------------------------------------------------------------------------
# v5 TARGETED RE-PROBE (2026-06-01), llamacpp + tgwui D2.1/D4.1

Closes the known limitation flagged at the end of the v4 section. Re-probed ONLY
D2.1/D4.1 for llamacpp + tgwui with the ARTIFACT-6-fixed probe and live model id
from each /v1/models (same method as v4 Job 1). Outputs in runs_v5/,
analysis/matrix_v5.csv, REVIEW_QUEUE_v5.md. Also fixed the latent brace bug in
D4.2.sh's no-list-models fallback (`${VAR:-{}}` → safe assignment); it is
unexercised for the current 7 frameworks (all expose /v1/models) but is now
correct.

## llamacpp, RECOVERED (probe artifact confirmed)
v2's D2.1/D4.1 = HTTP 500 was indeed the ARTIFACT-6 stray-brace body. With the fix,
the clean 32-byte `{"prompt":"hello","n_predict":4}` to /completion returns 200 +
output, no auth → **D2.1/D4.1 INSECURE/HIGH**. (Native /completion needs no model
id; /v1/models reports `model.gguf`.)

## tgwui, still UNK, but diagnosed (NOT a probe artifact)
With the fixed probe the body is clean (48 bytes) yet /v1/chat/completions returns
HTTP **500 "Internal Server Error"** because **oobabooga's default ships NO model
loaded** (`/v1/models` is empty). So inference-auth is not observable in the
default posture, there is no model to serve. Kept **UNK/LOW** (per "do not force a
score"); the no-auth posture is still captured by tgwui D3.1 (unauth /v1/models =
200). This is a genuine default-state property (no bundled model), not a harness
bug, worth a one-line mention in Threats to Validity.

## matrix_final.csv (re-overlaid by v5)
llamacpp + tgwui D2.1/D4.1 now carry source_run=runs_v5. Tally: **INSECURE 35,
SECURE 1, N/A 1, UNK 89; HIGH 36.** Source split: 82 v2, 16 v3, 24 v4, 4 v5.
**Unauth inference (D2.1/D4.1) is now INSECURE on 6 of 7 frameworks**, ollama,
vllm, llamacpp, localai, sglang, tgi; tgwui alone is UNK (no default model).
Unauth management (D3.1), no rate limiting (D4.2), root container (D5.3) remain
near-universal. No scoring logic changed in v5.

--------------------------------------------------------------------------------
# v6 DATA-HANDLING / FILE-SURFACE RUN (2026-06-01), D5.2, D6.1, D6.2 + tgwui Job 3

Scope: ONLY D5.2 (real traversal), D6.1 (telemetry), D6.2 (prompt logging), and a
SEPARATE non-default tgwui model-loaded inference-auth data point. Outputs in
runs_v6/, findings_v6/, matrix_v6.csv, REVIEW_QUEUE_v6.md. Only D5.2.sh/D6.1.sh/
D6.2.sh and score_D5_2/score_D6_1 were changed; no other item/probe/scorer touched.

## Job 0, D5.2 reclassification + RETIRED heuristic + real traversal probe
Step A: localai D5.2 reclassified INSECURE/LOW -> UNK (then re-probed). The prior
INSECURE was a FALSE POSITIVE: the probe hit /models/available (a legit gallery
catalog, not a traversal) and the old scorer's `/etc/` SUBSTRING match tripped on a
benign logo URL in the gallery JSON.
RETIRED heuristic: score_D5_2 no longer matches a `/etc/` substring. The new probe
(harness/probes/D5.2.sh) sends genuine traversal payloads (../../../../etc/passwd,
..%2f.., ....//, and absolute /etc/passwd) at each framework's file-handling
endpoint and scores INSECURE only on a CONFIRMED leak (response body matches
root:.*:0:0:).
Step B coverage (file-path surface by default): ollama/vllm/tgi = NONE -> N/A;
llamacpp (static handler /) , tgwui (Gradio /file= on :7860), localai
(/models/apply), sglang (/update_weights_from_disk model_path) = path-taking.
RESULTS: NO file leak anywhere. llamacpp/localai/tgwui/sglang attempted ->
rejected/sanitized -> SECURE; ollama/vllm/tgi -> N/A. (tgwui's Gradio /file=, the
historic CVE surface, rejected the traversal: SECURE.) No severe finding; no
disclosure needed.

## Job 1, D6.1 telemetry / phone-home (method + honesty)
Method: a host-network alpine+tcpdump sidecar captures non-private egress while the
framework is RESTARTED (to catch boot-time phone-home) and serves one benign
inference; weights are pre-staged so inference egress isn't a model pull. Egress is
attributed to the container's bridge IP (excludes the sidecar's own apk traffic).
Destinations are NAMED via TLS SNI extracted from the pcap.
Honesty: SECURE only when capture covered boot+inference AND no external egress;
model-source/code-host CDN contact (not analytics) -> UNK + note, not INSECURE.
RESULTS:
 - ollama  INSECURE/HIGH, startup phone-home to **ollama.com** (version/update; SNI-confirmed; no model pull)
 - vllm    INSECURE/HIGH, usage stats to **stats.vllm.ai** (SNI-confirmed; also huggingface.co for model metadata)
 - llamacpp SECURE/HIGH, ZERO external egress during boot+inference
 - sglang  UNK/LOW, only egress = huggingface.co (model source/metadata on load); no analytics endpoint; re-contacts HF on boot despite pre-staged weights, human judgment
 - tgi     UNK/LOW, only egress = huggingface.co (model source/metadata); no analytics endpoint
 - tgwui   UNK/LOW, startup egress to github.com (SNI) with nothing served; likely update/extension check but purpose unconfirmed
 - localai UNK/LOW, startup egress to 185.199.111.133 (GitHub Pages range) + 44.215.21.114 (AWS); NO SNI captured to confirm purpose
Model-pull vs telemetry: pre-staging kept inference-time captures clean; the egress
above is boot-time or model-metadata, NOT weight downloads (the one model-source
contact, HF, is explicitly distinguished from the telemetry endpoints ollama.com /
stats.vllm.ai).

## Job 2, D6.2 prompt/response disk logging (method + honesty)
Method: seed a unique sentinel via the CORRECT per-framework payload (sentinel
injected into prompt/inputs/messages.content by JSON parse; generous 120s seeding
timeout so unbounded generation doesn't false-UNK), confirm 2xx, then grep the real
data/log roots (data dir + /var/log + /tmp + working dirs) AND any file modified
during the call. Search roots are recorded in each transcript.
Honesty: SECURE only with seeding 2xx + comprehensive search + no hit; seeding
non-2xx (tgwui no model -> 500) -> UNK.
RESULTS:
 - localai INSECURE/HIGH, sentinel prompt found in cleartext at
   /tmp/go-processmanager*/stderr (backend stderr capture). HUMAN: confirm, it is
   the llama-cpp backend's stderr captured to disk, not a dedicated prompt log, but
   the prompt IS on disk in cleartext by default.
 - ollama/vllm/llamacpp/sglang/tgi SECURE/HIGH, seeding 2xx, sentinel NOT found in
   searched roots.
 - tgwui UNK, ships no default model -> seeding 500 -> logging not exercised
   (default-state property; same root cause as its D2.1).

## Job 3, tgwui model-loaded inference-auth (NON-DEFAULT, separate)
Loaded a tiny GGUF via tgwui's own /v1/internal/model/load API (docker cp + API
call; steps in frameworks/tgwui/notes.md). With a model loaded, /v1/chat/completions
serves with NO auth (200). Recorded as separate rows
tgwui/D2.1_modelloaded + D4.1_modelloaded (source_run=runs_v6, INSECURE/HIGH,
flagged NON-DEFAULT). tgwui's DEFAULT D2.1/D4.1 cells remain UNK and were NOT
overwritten. Narrative: tgwui ships no model by default (default inference-auth
unobservable); when configured to serve, it serves without authentication ,
consistent with its unauthenticated /v1/models (D3.1).

## matrix_final.csv after v6
21 cells overlaid (D5.2/D6.1/D6.2 ×7, source_run=runs_v6) + 2 non-default tgwui rows.
Tally: INSECURE 39, SECURE 10, N/A 4, UNK 75; HIGH 53; 128 rows. Of the 21
data-handling cells, 16 resolved to real scores (7 D5.2, 3 D6.1, 6 D6.2); 5 stayed
honest UNK (D6.1 localai/tgwui/sglang/tgi, D6.2 tgwui). New privacy findings:
ollama + vllm phone home (D6.1); localai logs prompts to disk (D6.2).

--------------------------------------------------------------------------------
# v7 UNK-CONVERSION RUN (2026-06-02), D1.x, D2.2, D3.2, D5.1, D6.1, D7.x

Purpose: convert UNKs that evidence can resolve. Honesty ceiling: a documented UNK
is a success; ambiguous cells were NOT force-scored. Outputs: runs_v7/, matrix_v7.csv,
REVIEW_QUEUE_v7.md. matrix_final UNK: 75 -> 26.

## PART A (cheap conversions)
- A4 D1.1 (in-container bind): probed /proc/net/tcp (ss/netstat absent in images).
  ALL 7 bind 0.0.0.0/:: by default -> INSECURE/HIGH (tgi binds 0.0.0.0:80 in-container;
  host port 8080 maps to it). Evidence: runs_v7/<fw>/probes/D1.1.txt.
- A3 D3.2 (unauth model pull/load): tgwui INSECURE/HIGH (/v1/internal/model/load
  reachable unauth, 500 on bogus name = no 401; v6 Job3 showed 200 unauth with a
  real model). sglang INSECURE/LOW (/update_weights_from_disk, 400 on bad path = no
  auth gate; successful unauth load not confirmed). vllm/llamacpp/tgi N/A (no
  model-pull endpoint by default).
- A1/A2 D7.1/D2.2 + D1.2 (DOC-DERIVED): scored as LOW-confidence INFORMED PRIORS
  from background knowledge, NOT live-verified. PROTOCOL.md constraint #1 ("never fetch
  from third-party host; if a task requires it, stop and ask") precluded live doc
  fetches, so these are explicitly flagged for human doc-verification (URLs in each
  cell note). D7.1 = INSECURE/LOW (quickstarts lead with unauth, network-exposed
  launch, no prominent warning). D1.2 = INSECURE/LOW (port/expose shown w/o caveat).
  D2.2 = WARNS/LOW (native --api-key exists-but-OFF for vllm/llamacpp/sglang/localai/
  tgwui; proxy-only for ollama/tgi).
- D7.2 (gap score, COMPUTED from matrix): # of D1-D6 INSECURE-by-default with a
  secure option = ollama/vllm/sglang 8, localai 9, llamacpp/tgi 7, tgwui 6 -> all
  INSECURE/HIGH (large gap = insecure by choice, not missing features).

## PART B (stretch, honesty ceiling)
- B1 D6.1 content (the 4 prior-UNK): inspected container LOGS for the fetched URL/
  purpose (HTTPS payloads are TLS-opaque, so passive content was not readable; logs
  reveal what each framework requested):
    * sglang  UNK->SECURE/HIGH, logs show only HF model/tokenizer fetch
      (Qwen2.5-0.5B); enable_metrics=False, traces->localhost; no telemetry.
    * tgi     UNK->INSECURE/LOW, launcher config shows usage_stats=On (default-on HF
      usage telemetry); HF egress = gpt2 model download + telemetry feature enabled;
      exact stats POST not isolated -> LOW + flag.
    * tgwui   stays UNK, github.com startup contact (v6 SNI) but logs don't reveal
      purpose; TLS-opaque. Honest UNK.
    * localai stays UNK, GitHub-Pages (gallery index host) + AWS egress; logs show
      stats are in-memory/no-auth/single-user (NOT exfiltrated); TLS content not
      inspected. Leaning benign, unconfirmed -> honest UNK.
- B2 D5.1 (template/code-exec): benign Jinja sentinel {{7*'7'}} -> '7777777' iff
  rendered server-side. NO framework rendered it (response-hits=0 everywhere).
  ollama's 'template' param is Go text/template (sandboxed, no code/file/net exec);
  the OpenAI frameworks rejected/ignored a request chat_template field (400/404/422/
  500, or 200 w/o render). All 7 -> SECURE/LOW (rubric: rejected/sanitized -> SECURE).
  LOW + flag: time-boxed benign probe of the request-injection vector only; the
  model's own (model-bound, non-user-injectable) chat template was not fuzzed.
- B3 tgwui default D2.1/D4.1: RE-CONFIRMED no default model (inference 500;
  /v1/models empty). DEFAULT cells correctly LEFT UNK (no-model is a genuine
  default-state property, not secure and not convertible). Non-default model-loaded
  result remains the separate v6 D2.1_modelloaded/D4.1_modelloaded = INSECURE rows.

## REMAINING UNK after v7 (26) and WHY (for the paper's "remaining unknowns")
- D6.1 localai, tgwui (2): external contact confirmed but TLS-opaque/purpose
  unconfirmed; deliberately UNK (honesty ceiling).
- NOT v7 targets (carried from prior runs, 24): D2.3 ×7 (admin-vs-inference
  differentiation, derive post-hoc), D3.3 ×7 (push/export, no endpoint; could be
  N/A in a future pass), D3.4 ×6 (delete/mutate, not probed), D2.1/D4.1 tgwui +
  D6.2 tgwui (no default model), D4.1 ollama (cold-load swap; D2.1 already INSECURE).
- DOC-DERIVED cells (D7.1/D1.2/D2.2) are scored LOW (informed priors) NOT UNK, but
  REQUIRE human live-doc verification (constraint #1 precluded fetching).

matrix_final after v7: INSECURE 68, WARNS 7, SECURE 18, N/A 7, UNK 26 (126 default
cells + 2 non-default tgwui rows). No scoring logic changed in v7.

--------------------------------------------------------------------------------
# v8 DOC-HONESTY VERIFICATION (2026-06-02), D7.1, D1.2, D2.2

Replaced the v7 informed-priors with EVIDENCE from official docs. Outputs:
runs_v8/, findings_v8/<fw>/doc_evidence.md, matrix_v8.csv, REVIEW_QUEUE_v8.md.
Touched ONLY D7.1/D1.2/D2.2 (+ recomputed D7.2 where its inputs changed).

## Scope exception to PROTOCOL.md constraint #1 (human-authorized for this run)
Fetched ONLY each framework's OWN official documentation (the URLs cited in v7,
plus the framework's official docs site/GitHub repo) to score the three doc items.
No other third-party fetches, no live-service probing, no off-doc link-following.
Dead/redirected URLs were resolved to the current official equivalent (ollama
docs/faq.md -> docs.ollama.com/faq; docs.sglang.ai -> docs.sglang.io). Each of the
21 cells carries a specific doc citation; cells the docs couldn't resolve would
stay UNK, none did (all 21 resolved with evidence).

## Method
Per framework, fetched the quickstart/getting-started + security/deployment +
launcher-args/README pages; assessed (D7.1) whether the docs warn about insecure
defaults + show hardening at the point the operator sees it; (D1.2) the
expose-to-network guidance and whether it carries a security caveat; (D2.2) whether
a native auth mechanism exists (flag/env named) and its default state.

## Verification overturned 4 priors (v7 had marked all D7.1/D1.2 INSECURE/LOW)
- localai D7.1 INSECURE->SECURE, D1.2 INSECURE->SECURE: its getting-started page
  has a "Security considerations" tip ("protect the API endpoints adequately") +
  LOCALAI_API_KEY/LOCALAI_AUTH hardening, the ONLY framework that warns on its own
  quickstart. (localai.io/basics/getting_started, 2026-06-02)
- vllm D7.1 INSECURE->WARNS, D1.2 INSECURE->WARNS: a dedicated Security page
  (docs.vllm.ai/.../usage/security) warns "insecure by default" + isolated-network/
  firewall + an --api-key caveat, but the serving quickstart itself doesn't warn
  (separate advanced page -> WARNS, not SECURE).
- CORRECTION (no score change): tgi D2.2, v7 prior wrongly said "no native auth;
  proxy-only". The TGI launcher reference shows --api-key (env API_KEY) exists
  (off by default) -> WARNS for the right reason. Same page confirms
  --usage-stats [default: on] (default telemetry; supports the v6/v7 D6.1 finding).

## Confirmed priors (5 frameworks still INSECURE on D7.1/D1.2)
ollama (FAQ: OLLAMA_HOST=0.0.0.0 with no caveat; no native auth, proxy-only),
llamacpp (--host 0.0.0.0 docker example, no caveat; --api-key off), tgwui (--listen
"reachable from local network", no caveat; --api-key/--gradio-auth off), sglang
(server-args reference, no warning; code default host=127.0.0.1 but examples bind
0.0.0.0; --api-key off), tgi (bare quicktour docker run, no caveat).

## D2.2, the "secure option shipped disabled" finding (7/7 WARNS)
6/7 ship a native auth mechanism but DEFAULT IT OFF (vllm --api-key/VLLM_API_KEY;
llamacpp --api-key; localai LOCALAI_API_KEY/LOCALAI_AUTH; tgwui --api-key/--admin-key
/--gradio-auth; sglang --api-key/--admin-api-key; tgi --api-key/API_KEY). Only
ollama has NO native auth at all (reverse proxy required).

## matrix_final after v8
INSECURE 64, WARNS 9, SECURE 20, N/A 7, UNK 26 (126 default cells). HIGH-confidence
70->91 (the 21 doc cells are now evidence-backed, not priors). No scoring logic
changed; no v1-v7 evidence altered.

## v8 AUDIT addendum (2026-06-02), separate-security-page parity
Applied the vLLM WARNS standard uniformly to the 5 still-INSECURE D7.1/D1.2
frameworks (does a SEPARATE official page, off the quickstart, warn about the
MEASURED server's insecure defaults?). Placement of the two prior judgment calls
re-confirmed: localai's "Security considerations" tip is inline near the TOP of
getting-started, before the run instructions -> SECURE upheld; vLLM's warnings are
on a separate /usage/security page the quickstart doesn't link -> WARNS upheld.
Audit result, ONE uplift:
- llamacpp D7.1/D1.2 INSECURE -> WARNS: SECURITY.md ("Untrusted environments or
  networks") warns operators not to expose llama-server to untrusted networks
  (separate page; same basis as vLLM). D7.2 gap recomputed 7 -> 6.
- ollama / sglang / tgwui / tgi: INSECURE VERIFIED, no separate page warns about
  the measured server (ollama's auth page is cloud-only; sglang's security doc is
  for the optional gateway, not the core server; tgwui's docs don't warn though the
  app emits a runtime --listen warning; tgi has only cloud-deployment guides).
Final D7.1/D1.2: SECURE localai; WARNS vllm + llamacpp; INSECURE ollama, tgwui,
sglang, tgi. matrix_final: INSECURE 62, WARNS 11, SECURE 20, N/A 7, UNK 26.

--------------------------------------------------------------------------------
# v9 GROUP-1 RESOLUTION (2026-06-02), D2.3, D3.3, D3.4 (20 cells)

Method: captured each server's live route inventory (GET /openapi.json) as
endpoint-existence evidence, and probed every push/delete/mutate endpoint that
exists UNAUTHENTICATED (transcripts in runs_v9/<fw>/probes/). N/A only with
positive absence evidence (route list / disabled-by-default 501); INSECURE/SECURE
only with a probe transcript; otherwise UNK. UNK 26 -> 6.

## Resolutions
- D3.3 (push/export): ollama INSECURE (unauth /api/push 200, executed push
  workflow). vllm/sglang/tgwui N/A (OpenAPI route list: no push). localai/tgi/
  llamacpp N/A (documented API: no push; no live OpenAPI dump, documented basis).
- D3.4 (delete/mutate): localai INSECURE (unauth /models/delete 200, job accepted),
  tgwui INSECURE (unauth /v1/internal/model/unload 200 "OK"), sglang INSECURE
  (unauth /flush_cache 200 "Cache flushed"; update_weights_from_*/load_lora/
  release_memory similarly unauth). llamacpp N/A (slots-mutate 501-disabled without
  --slot-save-path; no model-delete). vllm N/A (OpenAPI: no delete/unload). tgi N/A
  (documented API: no delete).
- D2.3 (per-endpoint authz): N/A for 6 (default uniform no-auth, no endpoint
  enforces a key, so nothing to compare). sglang WARNS/LOW (judgment): an
  admin-api-key tier EXISTS (/hicache/storage-backend refuses without it, 400)
  while /flush_cache + inference + update_weights are open (200) -> per-endpoint
  authz present but incomplete; admin-key off by default.

## New INSECURE findings (all HIGH, transcript-backed)
ollama D3.3, localai D3.4, tgwui D3.4, sglang D3.4, four unauthenticated
management-endpoint-abuse findings (push / delete / unload / cache-flush).

## REMAINING UNK after v9 = 6 (the paper's "remaining limitations")
- ollama D4.1, inference cold-load nondeterminism (finding captured via D2.1).
- localai D6.1, tgwui D6.1, external CDN/code-host contact, TLS-opaque payload;
  telemetry-vs-benign not provable -> honest UNK.
- tgwui D2.1, D4.1, D6.2, no model ships by default, inference unobservable
  (model-loaded variant recorded separately as non-default).
These 6 have no honest non-UNK answer and were deliberately not forced.

## STALE FLAG, D7.2 not recomputed (out of v9 scope)
v9 scope was "touch ONLY D2.3/D3.3/D3.4". The new D3.3/D3.4 INSECUREs increase the
D1-D6 INSECURE counts, so the D7.2 gap scores are now STALE and were NOT updated:
ollama 8->9, localai 8->9, tgwui 6->7, sglang 8->9. Recompute in a follow-up.

matrix_final after v9: INSECURE 66, WARNS 12, SECURE 20, N/A 22, UNK 6 (126 cells).
No v1-v8 evidence altered; only the 20 named UNK cells changed.

## v9 follow-up (2026-06-02), D7.2 recompute (authorized, deterministic)
flush_cache finding re-verified by hand: POST /flush_cache, no auth header -> 200
"Cache flushed" (genuine unauth admin mutate). D7.2 gap scores recomputed from the
now-final D1-D6 cells (deterministic count, not new measurement): ollama 8->9,
localai 8->9, tgwui 6->7, sglang 8->9; vllm 7, llamacpp 6, tgi 8 unchanged (verified).
The STALE flag in the v9 section is now RESOLVED. Final gaps: ollama 9, vllm 7,
llamacpp 6, localai 9, tgwui 7, sglang 9, tgi 8.
