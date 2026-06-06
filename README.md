# Insecure by Default?, reproducibility artifact

A controlled, **local-testbed** measurement of the default security posture of
self-hosted LLM serving frameworks. This artifact contains the measurement
harness, the per-framework install/config scaffolding, the consolidated results
matrix, and the raw transcripts that back every scored cell. It accompanies the
paper of the same name and is intended to be **re-runnable** as frameworks evolve.

See `PROTOCOL.md` for the measurement methodology (the 18-item D1–D7 checklist,
the scoring rubric, and the integrity constraints).

## What it measures

For each framework, what a fresh documentation-following install exposes on the
local host *before* any operator hardening, network exposure, authentication,
unauthenticated management/inference, code/file surface, telemetry/logging, and
documentation honesty. Each (framework, item) cell is scored with a transcript
reference; see `PROTOCOL.md`.

## Frameworks and snapshot

Seven headless, deployable serving frameworks were measured. Each is pinned by
container image digest; installs followed each project's official quickstart over
the snapshot window **2026-05-30 to 2026-06-02**.

| Framework | Image (digest-pinned) | Version |
|-----------|------------------------|---------|
| Ollama    | `ollama/ollama:latest`                                   | 0.24.0 |
| vLLM      | `vllm/vllm-openai:latest`                                | 0.22.0 |
| llama.cpp | `ghcr.io/ggml-org/llama.cpp:server`                      | rolling (digest-pinned) |
| LocalAI   | `localai/localai:latest`                                 | rolling (digest-pinned) |
| TGWUI     | `atinoda/text-generation-webui:default-cpu`              | rolling (digest-pinned) |
| SGLang    | `lmsysorg/sglang:latest`                                 | rolling (digest-pinned) |
| TGI       | `ghcr.io/huggingface/text-generation-inference:3.0-intel-cpu` | 3.0 (CPU) |

**Mixed-environment note.** The testbed is CPU-based. TGI is measured using its
**CPU** image (`3.0-intel-cpu`); the other six run on the same host. This is a
property of the testbed, not of the frameworks, and is relevant only where a
finding could plausibly differ on a GPU build, flagged where it applies in the
notes and review queues.

`frameworks/jan/` and `frameworks/lmstudio/` are **out of scope** (desktop GUI
applications, not headless servers); their scaffolding is included for
completeness but they are not part of the seven measured frameworks.

> **Models.** Substrate model weight files (`*.gguf`) are **not** included
> (size). Each framework's `install.sh` documents how its model is obtained.

## How to run

The harness drives everything from the `Makefile` (probes target loopback only):

```sh
make help                      # list targets
make harness                   # harness self-tests
make install FRAMEWORK=ollama  # bring up a framework (its documented quickstart)
make wait    FRAMEWORK=ollama  # readiness-gate (health/models endpoint)
make probe   FRAMEWORK=ollama  # run the D1–D7 probes, save raw transcripts
make score   FRAMEWORK=ollama  # derive scores.csv from the transcripts
make matrix                    # rebuild the consolidated matrix
```

Each probe lives in `harness/probes/D<X>.<Y>.sh`; shared helpers (loopback-only
curl wrapper, readiness wait, redaction) are in `harness/lib/`.

## How the matrix maps to the paper's claims

`analysis/matrix_final.csv` is the **authoritative** result. Columns:

```
framework, item_id, score, confidence, evidence_file, notes, source_run
```

- `evidence_file` points to the raw transcript that backs the cell. Every
  transcript referenced by `matrix_final.csv` is included in this artifact
  (under `runs_v*/…` and `findings_v8/…`), so each cell is independently
  checkable.
- `source_run` records which measurement run the authoritative cell came from
  (the study iterated across runs `v2`–`v9` as the harness was fixed and
  re-validated).
- `matrix.csv` and `matrix_v2.csv … matrix_v9.csv` are the per-run intermediate
  matrices, retained for provenance. They are **superseded** by
  `matrix_final.csv`; some intermediate matrices reference transcripts that were
  not bundled (only `matrix_final`'s evidence set is shipped in full).
- The two non-default rows (`tgwui … _modelloaded`) are reported **separately**
  and are never folded into the 126-cell default tally.

## Honest UNK / limitations

- These are **shipped defaults on a controlled local testbed**, not a
  measurement of how frameworks are deployed in the wild. No deployment-prevalence
  claims are made.
- `UNK` cells (e.g. some encrypted external contacts that could not be classified,
  and frameworks that ship no default model so a default inference posture is
  unobservable) are reported as `UNK`, not guessed. All `LOW`/`UNK` cells are
  enumerated in `analysis/REVIEW_QUEUE*.md`.
- The framework set is non-exhaustive and reflects a snapshot of a fast-moving
  ecosystem; the harness is released precisely so the measurement can be re-run.
- The v1 shakedown evidence (`analysis/v1_evidence/`) was captured before three
  scorer fixes; the committed scores were re-derived from the same raw
  transcripts afterward (see `analysis/INSTRUMENT_NOTES.md`).
