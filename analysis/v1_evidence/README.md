# v1 shakedown, raw evidence archive

`v1_raw_evidence.tar.gz` preserves the complete raw artifacts of the v1 batch
run so the evidence survives a fresh checkout. The loose files under `runs/` are
gitignored by design (only `runs/<fw>/scores.csv` is tracked); this tarball is
the tracked, durable copy.

- **Contents:** everything under `runs/` at v1 commit time, 177 files:
  153 probe transcripts (`runs/<fw>/probes/*.txt`), 9 install logs, 22
  config-snapshot files (`docker inspect` / version / env), 9 `scores.csv`,
  and `runs/batch.log` (full batch console log).
- **Integrity:** see `SHA256SUMS` (verify: `sha256sum -c SHA256SUMS`).
- **Inventory:** see `MANIFEST.txt` (path + byte size of every archived file).

## Restore
```sh
# from repo root, extracts runs/ back into place
tar xzf analysis/v1_evidence/v1_raw_evidence.tar.gz
```

## Double-blind hygiene
Scanned before archiving: no machine hostname, author handle, or email present.
Docker `"Hostname"` fields are container IDs (random hashes), not the host. The
only host path present is the generic `/home/anon`. If a future anonymized
artifact export needs even that removed, redact `/home/anon` at export time.

## Caveat
These are v1 transcripts captured BEFORE the 3 scorer fixes; the committed
`scores.csv` / `matrix.csv` were re-derived from these same transcripts after the
fixes. See `analysis/INSTRUMENT_NOTES.md`. The transcripts themselves are
unchanged raw evidence.
