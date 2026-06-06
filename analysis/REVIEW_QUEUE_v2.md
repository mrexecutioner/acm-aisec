# Review Queue, v2

> Regenerated after the v2 batch + targeted recovery of llamacpp (image rename
> fix). Every LOW-confidence and every UNK row is listed per framework with a
> transcript pointer. See analysis/INSTRUMENT_NOTES.md (v2 section) for the
> readiness/scope changes and the genuine startup failures (tgi, localai).

## ollama
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/ollama/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/ollama/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v2/ollama/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/ollama/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.3 | UNK | LOW | `runs_v2/ollama/probes/D3.3.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v2/ollama/probes/D4.1.txt` | curl exit 28 (request timed out, possible cold model load; cross-check D4.1) |
| D5.1 | UNK | LOW | `runs_v2/ollama/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/ollama/probes/D5.2.txt` | status 405 - inspect manually |
| D6.1 | UNK | LOW | `runs_v2/ollama/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/ollama/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 404) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/ollama/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/ollama/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## vllm
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/vllm/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/vllm/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/vllm/probes/D2.1.txt` | unexpected status 400 |
| D2.2 | UNK | LOW | `runs_v2/vllm/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/vllm/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs_v2/vllm/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs_v2/vllm/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/vllm/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v2/vllm/probes/D4.1.txt` | unexpected status 400 |
| D5.1 | UNK | LOW | `runs_v2/vllm/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D6.1 | UNK | LOW | `runs_v2/vllm/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/vllm/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 28) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/vllm/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/vllm/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## llamacpp
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/llamacpp/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/llamacpp/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/llamacpp/probes/D2.1.txt` | unexpected status 500 |
| D2.2 | UNK | LOW | `runs_v2/llamacpp/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/llamacpp/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs_v2/llamacpp/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs_v2/llamacpp/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/llamacpp/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v2/llamacpp/probes/D4.1.txt` | unexpected status 500 |
| D5.1 | UNK | LOW | `runs_v2/llamacpp/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/llamacpp/probes/D5.2.txt` | status 200 - inspect manually |
| D6.1 | UNK | LOW | `runs_v2/llamacpp/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/llamacpp/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 28) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/llamacpp/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/llamacpp/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## localai
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/localai/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/localai/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/localai/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs_v2/localai/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/localai/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v2/localai/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs_v2/localai/probes/D3.2.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.3 | UNK | LOW | `runs_v2/localai/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/localai/probes/D3.4.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.1 | UNK | LOW | `runs_v2/localai/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs_v2/localai/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs_v2/localai/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/localai/probes/D5.2.txt` | no status |
| D5.3 | UNK | LOW | `runs_v2/localai/probes/D5.3.txt` | no User field found |
| D6.1 | UNK | LOW | `runs_v2/localai/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/localai/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/localai/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/localai/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgwui
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/tgwui/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/tgwui/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/tgwui/probes/D2.1.txt` | unexpected status 422 |
| D2.2 | UNK | LOW | `runs_v2/tgwui/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/tgwui/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs_v2/tgwui/probes/D3.2.txt` | unexpected status 422 |
| D3.3 | UNK | LOW | `runs_v2/tgwui/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/tgwui/probes/D3.4.txt` | 405 method-not-allowed: revisit endpoint method |
| D4.1 | UNK | LOW | `runs_v2/tgwui/probes/D4.1.txt` | unexpected status 422 |
| D5.1 | UNK | LOW | `runs_v2/tgwui/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/tgwui/probes/D5.2.txt` | status 405 - inspect manually |
| D6.1 | UNK | LOW | `runs_v2/tgwui/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/tgwui/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 422) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/tgwui/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/tgwui/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## sglang
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/sglang/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/sglang/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/sglang/probes/D2.1.txt` | unexpected status 400 |
| D2.2 | UNK | LOW | `runs_v2/sglang/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/sglang/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs_v2/sglang/probes/D3.2.txt` | unexpected status 400 |
| D3.3 | UNK | LOW | `runs_v2/sglang/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/sglang/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v2/sglang/probes/D4.1.txt` | unexpected status 400 |
| D5.1 | UNK | LOW | `runs_v2/sglang/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/sglang/probes/D5.2.txt` | status 200 - inspect manually |
| D6.1 | UNK | LOW | `runs_v2/sglang/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/sglang/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 400) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/sglang/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/sglang/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgi
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v2/tgi/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v2/tgi/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v2/tgi/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs_v2/tgi/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v2/tgi/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v2/tgi/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs_v2/tgi/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs_v2/tgi/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v2/tgi/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v2/tgi/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs_v2/tgi/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs_v2/tgi/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v2/tgi/probes/D5.2.txt` | no status |
| D6.1 | UNK | LOW | `runs_v2/tgi/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v2/tgi/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v2/tgi/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v2/tgi/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |
