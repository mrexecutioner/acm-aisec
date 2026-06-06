# Review Queue, v6 (D5.2 real-traversal, D6.1 telemetry, D6.2 logging, tgwui Job 3)

> Honesty note: D6.1/D6.2 are privacy findings; absence of evidence != absence. UNK rows below state exactly what was checked / why inconclusive.

| framework | item | score | conf | what to check / why flagged |
|---|---|---|---|---|
| ollama | D6.1 | INSECURE | HIGH | phones home to ollama.com (version/update check) at startup by default; no model pull (weights pre-staged), SNI-confirm |
| vllm | D6.1 | INSECURE | HIGH | sends usage stats to stats.vllm.ai by default (SNI-confirmed); also contacts huggingface.co for model metadata |
| localai | D6.1 | UNK | LOW | startup egress to 185.199.111.133 (GitHub Pages range) + 44.215.21.114 (AWS); no TLS SNI captured to confirm purpose, l |
| localai | D6.2 | INSECURE | HIGH | sentinel prompt text found in plaintext log/data dir |
| tgwui | D6.1 | UNK | LOW | startup egress to github.com (SNI-confirmed) with no model/inference served, likely update/extension check (phone-home) |
| tgwui | D6.2 | UNK | LOW | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 500) - logging surface never exercised, cannot asses |
| sglang | D6.1 | UNK | LOW | only external egress = huggingface.co (model source/metadata on load, SNI-confirmed); no analytics endpoint observed; re |
| tgi | D6.1 | UNK | LOW | only external egress = huggingface.co (model source/metadata, SNI-confirmed); no analytics endpoint observed; HUMAN: jud |
| tgwui | D2.1_modelloaded | INSECURE | HIGH | NON-DEFAULT: served inference w/o auth after loading a model; does NOT change default D2.1 (UNK) |
| tgwui | D4.1_modelloaded | INSECURE | HIGH | NON-DEFAULT: same as D2.1_modelloaded |
