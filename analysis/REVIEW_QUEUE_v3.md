# Review Queue


## localai
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v3/localai/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v3/localai/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.2 | UNK | LOW | `runs_v3/localai/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v3/localai/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.3 | UNK | LOW | `runs_v3/localai/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v3/localai/probes/D3.4.txt` | 405 method-not-allowed: revisit endpoint method |
| D5.1 | UNK | LOW | `runs_v3/localai/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | INSECURE | LOW | `runs_v3/localai/probes/D5.2.txt` | 200 with file-system-looking content; needs human read of transcript |
| D6.1 | UNK | LOW | `runs_v3/localai/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v3/localai/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (HTTP 400) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v3/localai/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v3/localai/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |

## tgi
| item | score | conf | transcript | what to check |
|------|-------|------|------------|----------------|
| D1.1 | UNK | LOW | `runs_v3/tgi/probes/D1.1.txt` | bind addr is read from runs/<fw>/config_snapshot/ - manual check |
| D1.2 | UNK | LOW | `runs_v3/tgi/probes/D1.2.txt` | depends on docs language - human-judged at review |
| D2.1 | UNK | LOW | `runs_v3/tgi/probes/D2.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D2.2 | UNK | LOW | `runs_v3/tgi/probes/D2.2.txt` | doc-derived: does native auth exist? human-judged |
| D2.3 | UNK | LOW | `runs_v3/tgi/probes/D2.3.txt` | compare D2.1 vs D3.x results post-hoc |
| D3.1 | UNK | LOW | `runs_v3/tgi/probes/D3.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D3.2 | UNK | LOW | `runs_v3/tgi/probes/D3.2.txt` | no HTTP status line in transcript |
| D3.3 | UNK | LOW | `runs_v3/tgi/probes/D3.3.txt` | no HTTP status line in transcript |
| D3.4 | UNK | LOW | `runs_v3/tgi/probes/D3.4.txt` | no HTTP status line in transcript |
| D4.1 | UNK | LOW | `runs_v3/tgi/probes/D4.1.txt` | curl exit 56 (connection refused/reset, service likely down/unhealthy) |
| D4.2 | UNK | LOW | `runs_v3/tgi/probes/D4.2.txt` | server served only 0 genuine HTTP responses (200 failed/000) - server down/unhealthy, cannot assess throttling |
| D5.1 | UNK | LOW | `runs_v3/tgi/probes/D5.1.txt` | template/tool-exec exposure: subjective, framework-specific - human-judged |
| D5.2 | UNK | LOW | `runs_v3/tgi/probes/D5.2.txt` | no status |
| D6.1 | UNK | LOW | `runs_v3/tgi/probes/D6.1.txt` | telemetry inspection requires tcpdump + manual analysis - human-judged |
| D6.2 | UNK | LOW | `runs_v3/tgi/probes/D6.2.txt` | sentinel NOT logged, but seeding inference did not return 2xx (curl exit 56) - logging surface never exercised, cannot assess |
| D7.1 | UNK | LOW | `runs_v3/tgi/probes/D7.1.txt` | subjective doc read - human-judged |
| D7.2 | UNK | LOW | `runs_v3/tgi/probes/D7.2.txt` | derived from D1-D6 + docs after the fact - computed in matrix step |
