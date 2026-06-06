# Review Queue, v4

> v4: (Job 1) recovered D2.1/D4.1 for vllm, sglang, localai via a probe brace-bug
> fix + per-framework payloads; (Job 2) full TGI row via the CPU image
> (3.0-intel-cpu). Flagged (LOW/UNK) cells from the v4 runs only. For vllm/sglang/
> localai only D2.1+D4.1 were re-probed (both INSECURE/HIGH → nothing to flag);
> tgi was a full D1–D7 run. See analysis/INSTRUMENT_NOTES.md (v4 section).

## vllm
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v4/vllm/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v4/vllm/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v4/vllm/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v4/vllm/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v4/vllm/probes/D3.1.txt` | transcript missing (probe did not run) |
| D3.2 | UNK | LOW | `runs_v4/vllm/probes/D3.2.txt` | transcript missing (probe did not run) |
| D3.3 | UNK | LOW | `runs_v4/vllm/probes/D3.3.txt` | transcript missing (probe did not run) |
| D3.4 | UNK | LOW | `runs_v4/vllm/probes/D3.4.txt` | transcript missing (probe did not run) |
| D4.2 | UNK | LOW | `runs_v4/vllm/probes/D4.2.txt` | transcript missing |
| D5.1 | UNK | LOW | `runs_v4/vllm/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v4/vllm/probes/D5.2.txt` | transcript missing |
| D5.3 | UNK | LOW | `runs_v4/vllm/probes/D5.3.txt` | no docker inspect transcript |
| D6.1 | UNK | LOW | `runs_v4/vllm/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v4/vllm/probes/D6.2.txt` | no log-dir transcript |
| D7.1 | UNK | LOW | `runs_v4/vllm/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v4/vllm/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## sglang
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v4/sglang/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v4/sglang/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v4/sglang/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v4/sglang/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v4/sglang/probes/D3.1.txt` | transcript missing (probe did not run) |
| D3.2 | UNK | LOW | `runs_v4/sglang/probes/D3.2.txt` | transcript missing (probe did not run) |
| D3.3 | UNK | LOW | `runs_v4/sglang/probes/D3.3.txt` | transcript missing (probe did not run) |
| D3.4 | UNK | LOW | `runs_v4/sglang/probes/D3.4.txt` | transcript missing (probe did not run) |
| D4.2 | UNK | LOW | `runs_v4/sglang/probes/D4.2.txt` | transcript missing |
| D5.1 | UNK | LOW | `runs_v4/sglang/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v4/sglang/probes/D5.2.txt` | transcript missing |
| D5.3 | UNK | LOW | `runs_v4/sglang/probes/D5.3.txt` | no docker inspect transcript |
| D6.1 | UNK | LOW | `runs_v4/sglang/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v4/sglang/probes/D6.2.txt` | no log-dir transcript |
| D7.1 | UNK | LOW | `runs_v4/sglang/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v4/sglang/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## localai
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v4/localai/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v4/localai/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v4/localai/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v4/localai/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v4/localai/probes/D3.1.txt` | transcript missing (probe did not run) |
| D3.2 | UNK | LOW | `runs_v4/localai/probes/D3.2.txt` | transcript missing (probe did not run) |
| D3.3 | UNK | LOW | `runs_v4/localai/probes/D3.3.txt` | transcript missing (probe did not run) |
| D3.4 | UNK | LOW | `runs_v4/localai/probes/D3.4.txt` | transcript missing (probe did not run) |
| D4.2 | UNK | LOW | `runs_v4/localai/probes/D4.2.txt` | transcript missing |
| D5.1 | UNK | LOW | `runs_v4/localai/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v4/localai/probes/D5.2.txt` | transcript missing |
| D5.3 | UNK | LOW | `runs_v4/localai/probes/D5.3.txt` | no docker inspect transcript |
| D6.1 | UNK | LOW | `runs_v4/localai/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v4/localai/probes/D6.2.txt` | no log-dir transcript |
| D7.1 | UNK | LOW | `runs_v4/localai/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v4/localai/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgi
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v4/tgi/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v4/tgi/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v4/tgi/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v4/tgi/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.2 | UNK | LOW | `runs_v4/tgi/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs_v4/tgi/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v4/tgi/probes/D3.4.txt` | no HTTP status line in transcript |
| D5.1 | UNK | LOW | `runs_v4/tgi/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v4/tgi/probes/D5.2.txt` | status 200 - inspect manually |
| D6.1 | UNK | LOW | `runs_v4/tgi/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v4/tgi/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 422) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v4/tgi/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v4/tgi/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |
