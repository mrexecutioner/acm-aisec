# Review Queue

> Auto-populated by `harness/score.py --append-review-queue` after each framework
> completes its probe + scoring step. Every LOW-confidence row and every UNK row
> appears here with a pointer to its transcript and a one-line "what to check"
> note.

> Human action: walk this list top-to-bottom in the single end-of-run
> verification pass. For each row, open the transcript, accept / overwrite /
> escalate. Then spot-check HIGH-confidence INSECURE rows in `analysis/matrix.csv`.

> REGENERATED 2026-05-30 after a scorer fix. The original batch run mis-scored
> D4.2 (rate limiting): synthetic `HTTP/1.1 000` curl-error lines were counted as
> served responses, so 6 frameworks whose servers were DOWN were scored
> INSECURE/HIGH ("0/200 throttled"). Fixed in harness/lib/score_item.py; scores
> below are the corrected re-score from the same saved transcripts. Full writeup:
> analysis/INSTRUMENT_NOTES.md (ARTIFACT-2).

## ollama
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/ollama/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/ollama/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/ollama/probes/D2.1.txt` | curl exit 28 (request timed out, possible cold model load; cross-check D4.1) |
| D2.2 | UNK | LOW | `runs/ollama/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/ollama/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.3 | UNK | LOW | `runs/ollama/probes/D3.3.txt` | no HTTP status line in transcript |
| D5.1 | UNK | LOW | `runs/ollama/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/ollama/probes/D5.2.txt` | status 405 - inspect manually |
| D6.1 | UNK | LOW | `runs/ollama/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/ollama/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 404) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/ollama/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/ollama/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## vllm
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/vllm/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/vllm/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/vllm/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/vllm/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/vllm/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/vllm/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/vllm/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs/vllm/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/vllm/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs/vllm/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/vllm/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/vllm/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/vllm/probes/D5.2.txt` | no status |
| D6.1 | UNK | LOW | `runs/vllm/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/vllm/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/vllm/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/vllm/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## llamacpp
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/llamacpp/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/llamacpp/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/llamacpp/probes/D2.1.txt` | transcript missing (probe did not run) |
| D2.2 | UNK | LOW | `runs/llamacpp/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/llamacpp/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/llamacpp/probes/D3.1.txt` | transcript missing (probe did not run) |
| D3.2 | UNK | LOW | `runs/llamacpp/probes/D3.2.txt` | transcript missing (probe did not run) |
| D3.3 | UNK | LOW | `runs/llamacpp/probes/D3.3.txt` | transcript missing (probe did not run) |
| D3.4 | UNK | LOW | `runs/llamacpp/probes/D3.4.txt` | transcript missing (probe did not run) |
| D4.1 | UNK | LOW | `runs/llamacpp/probes/D4.1.txt` | transcript missing (probe did not run) |
| D4.2 | UNK | LOW | `runs/llamacpp/probes/D4.2.txt` | transcript missing |
| D5.1 | UNK | LOW | `runs/llamacpp/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/llamacpp/probes/D5.2.txt` | transcript missing |
| D5.3 | UNK | LOW | `runs/llamacpp/probes/D5.3.txt` | no docker inspect transcript |
| D6.1 | UNK | LOW | `runs/llamacpp/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/llamacpp/probes/D6.2.txt` | no log-dir transcript |
| D7.1 | UNK | LOW | `runs/llamacpp/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/llamacpp/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## lmstudio
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/lmstudio/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/lmstudio/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/lmstudio/probes/D2.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/lmstudio/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/lmstudio/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/lmstudio/probes/D3.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/lmstudio/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs/lmstudio/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/lmstudio/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs/lmstudio/probes/D4.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/lmstudio/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/lmstudio/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/lmstudio/probes/D5.2.txt` | no status |
| D5.3 | UNK | LOW | `runs/lmstudio/probes/D5.3.txt` | no User field found |
| D6.1 | UNK | LOW | `runs/lmstudio/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/lmstudio/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 7) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/lmstudio/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/lmstudio/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## localai
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/localai/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/localai/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/localai/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/localai/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/localai/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/localai/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/localai/probes/D3.2.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.3 | UNK | LOW | `runs/localai/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/localai/probes/D3.4.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.1 | UNK | LOW | `runs/localai/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/localai/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/localai/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/localai/probes/D5.2.txt` | no status |
| D5.3 | UNK | LOW | `runs/localai/probes/D5.3.txt` | no User field found |
| D6.1 | UNK | LOW | `runs/localai/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/localai/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/localai/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/localai/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgwui
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/tgwui/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/tgwui/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/tgwui/probes/D2.1.txt` | unexpected status 422 |
| D2.2 | UNK | LOW | `runs/tgwui/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/tgwui/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs/tgwui/probes/D3.2.txt` | unexpected status 422 |
| D3.3 | UNK | LOW | `runs/tgwui/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/tgwui/probes/D3.4.txt` | 405 method-not-allowed: revisit endpoint method |
| D4.1 | UNK | LOW | `runs/tgwui/probes/D4.1.txt` | unexpected status 422 |
| D5.1 | UNK | LOW | `runs/tgwui/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/tgwui/probes/D5.2.txt` | status 405 - inspect manually |
| D6.1 | UNK | LOW | `runs/tgwui/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/tgwui/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 422) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/tgwui/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/tgwui/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## jan
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/jan/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/jan/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/jan/probes/D2.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/jan/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/jan/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/jan/probes/D3.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/jan/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs/jan/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/jan/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs/jan/probes/D4.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/jan/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/jan/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/jan/probes/D5.2.txt` | no status |
| D5.3 | UNK | LOW | `runs/jan/probes/D5.3.txt` | no User field found |
| D6.1 | UNK | LOW | `runs/jan/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/jan/probes/D6.2.txt` | log-scan probe produced no clear verdict |
| D7.1 | UNK | LOW | `runs/jan/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/jan/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## sglang
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/sglang/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/sglang/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/sglang/probes/D2.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/sglang/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/sglang/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/sglang/probes/D3.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/sglang/probes/D3.2.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D3.3 | UNK | LOW | `runs/sglang/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/sglang/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs/sglang/probes/D4.1.txt` | curl exit 7 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/sglang/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/sglang/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/sglang/probes/D5.2.txt` | no status |
| D6.1 | UNK | LOW | `runs/sglang/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/sglang/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/sglang/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/sglang/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgi
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs/tgi/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs/tgi/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs/tgi/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs/tgi/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs/tgi/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs/tgi/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs/tgi/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs/tgi/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs/tgi/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs/tgi/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs/tgi/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs/tgi/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs/tgi/probes/D5.2.txt` | no status |
| D6.1 | UNK | LOW | `runs/tgi/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs/tgi/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs/tgi/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs/tgi/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |
