# Review Queue, v5

> v5: re-probed ONLY D2.1/D4.1 for llamacpp + tgwui with the ARTIFACT-6-fixed
> probe (and fixed the latent D4.2 brace bug). Results:
> - llamacpp D2.1/D4.1: RECOVERED to INSECURE/HIGH (v2's 500 was the stray-brace
>   artifact), nothing to flag.
> - tgwui D2.1/D4.1: still UNK, HTTP 500 "no model loaded" (oobabooga ships no
>   model by default), NOT a probe artifact. Flagged below. Its no-auth posture is
>   captured by D3.1 (unauth /v1/models = 200).

## tgwui (D2.1/D4.1, flagged)
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D2.1 | UNK | LOW | `runs_v5/tgwui/probes/D2.1.txt` | 500 = no model loaded by default; inference-auth unobservable without loading a model |
| D4.1 | UNK | LOW | `runs_v5/tgwui/probes/D4.1.txt` | same as D2.1 (identical probe) |
