# LLM Serving Framework Security Defaults, measurement harness
# See PROTOCOL.md and README.md.

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Measured set (v2): headless/deployable serving frameworks only.
# lmstudio + jan dropped, desktop GUI apps, outside the headless threat model
# (see analysis/INSTRUMENT_NOTES.md ARTIFACT-5). llama.cpp keeps the LM Studio/Jan
# engine represented as a deployed server.
FRAMEWORKS := ollama vllm llamacpp localai tgwui sglang tgi

ROOT := $(abspath .)
HARNESS := $(ROOT)/harness
FRAMEWORKS_DIR := $(ROOT)/frameworks

# ---- output-path parameterization (override for v2) -----------------------
# Defaults reproduce v1 layout; `make batch-v2` overrides these to runs_v2/ etc.
RUNS_DIRNAME     ?= runs
FINDINGS_DIRNAME ?= findings
MATRIX_NAME      ?= matrix.csv
RQ_NAME          ?= REVIEW_QUEUE.md
# Readiness ceiling per framework, in seconds (15 min for heavy GPU loads).
READY_CEILING    ?= 900

RUNS     := $(ROOT)/$(RUNS_DIRNAME)
FINDINGS := $(ROOT)/$(FINDINGS_DIRNAME)
ANALYSIS := $(ROOT)/analysis

# Args passed to score.py so it writes to the right (v1 or v2) paths.
SCORE_ARGS := --runs-dir $(RUNS_DIRNAME) --findings-dir $(FINDINGS_DIRNAME) \
              --matrix-name $(MATRIX_NAME) --review-queue-name $(RQ_NAME)

# Portable Python (POSIX uses python3, Windows Git Bash usually has only `python`).
PY := $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null || echo py)

# Per-framework paths (FRAMEWORK var must be passed for per-fw targets)
FW := $(FRAMEWORK)
FW_DIR := $(FRAMEWORKS_DIR)/$(FW)
FW_RUN := $(RUNS)/$(FW)

.PHONY: help harness install wait probe score summary clean batch batch-v2 matrix \
        _check_fw _ensure_runs

help:
	@echo "Targets:"
	@echo "  make harness                       - smoke-test the harness library"
	@echo "  make install FRAMEWORK=<name>      - run frameworks/<name>/install.sh"
	@echo "  make wait    FRAMEWORK=<name>      - poll readiness until 2xx (ceiling $(READY_CEILING)s)"
	@echo "  make probe   FRAMEWORK=<name>      - run all checklist probes"
	@echo "  make score   FRAMEWORK=<name>      - emit <runs>/<name>/scores.csv"
	@echo "  make summary FRAMEWORK=<name>      - emit <findings>/<name>/SUMMARY.md"
	@echo "  make clean   FRAMEWORK=<name>      - tear down containers/volumes"
	@echo "  make batch                         - full unattended run (v1 paths)"
	@echo "  make batch-v2                      - full unattended run into runs_v2/ etc."
	@echo "  make matrix                        - combine all scores.csv into <matrix>"
	@echo ""
	@echo "Frameworks in scope: $(FRAMEWORKS)"

# ---- internal guards ------------------------------------------------------

_check_fw:
	@if [ -z "$(FW)" ]; then echo "ERROR: pass FRAMEWORK=<name>"; exit 2; fi
	@if [ ! -d "$(FW_DIR)" ]; then echo "ERROR: no such framework dir: $(FW_DIR)"; exit 2; fi

_ensure_runs: _check_fw
	@mkdir -p "$(FW_RUN)/probes" "$(FW_RUN)/config_snapshot"

# ---- harness smoke test ---------------------------------------------------

harness:
	@bash "$(HARNESS)/lib/curl_local.sh" --selftest
	@$(PY) "$(HARNESS)/lib/redact.py" --selftest
	@$(PY) "$(HARNESS)/lib/score_item.py" --selftest
	@bash "$(HARNESS)/lib/wait_ready.sh" --selftest
	@echo "harness OK"

# ---- per-framework loop ---------------------------------------------------

install: _ensure_runs
	@echo "[install] $(FW)"
	@FRAMEWORK=$(FW) FW_DIR=$(FW_DIR) FW_RUN=$(FW_RUN) ROOT=$(ROOT) \
	  bash "$(FW_DIR)/install.sh" 2>&1 | tee "$(FW_RUN)/install.log" || \
	  echo "[install] $(FW) FAILED (exit captured in install.log)"

# Readiness gate: poll the framework's readiness endpoint until 2xx or ceiling.
# Records time-to-ready in $(FW_RUN)/ready.txt. Always exits 0 so batch continues;
# a genuine non-ready is a true negative the probes will reflect as UNK.
wait: _ensure_runs
	@echo "[wait] $(FW) (ceiling $(READY_CEILING)s)"
	@FRAMEWORK=$(FW) FW_DIR=$(FW_DIR) FW_RUN=$(FW_RUN) ROOT=$(ROOT) \
	  CEILING=$(READY_CEILING) bash "$(HARNESS)/lib/wait_ready.sh" || true

probe: _ensure_runs
	@echo "[probe] $(FW)"
	@set -e; for p in $(HARNESS)/probes/D*.sh; do \
	  pid=$$(basename $$p .sh); \
	  echo "  -> $$pid"; \
	  FRAMEWORK=$(FW) FW_DIR=$(FW_DIR) FW_RUN=$(FW_RUN) ROOT=$(ROOT) \
	    bash "$$p" || echo "  !! $$pid exited non-zero (transcript saved)"; \
	done

score: _check_fw
	@$(PY) "$(HARNESS)/score.py" --framework "$(FW)" --root "$(ROOT)" $(SCORE_ARGS)

summary: _check_fw
	@$(PY) "$(HARNESS)/score.py" --framework "$(FW)" --root "$(ROOT)" $(SCORE_ARGS) --summary

clean: _check_fw
	@echo "[clean] $(FW)"
	@if [ -f "$(FW_DIR)/compose.yml" ]; then \
	  docker compose -f "$(FW_DIR)/compose.yml" -p "secdefaults-$(FW)" down -v --remove-orphans 2>/dev/null || true; \
	fi

# ---- batch ----------------------------------------------------------------

batch:
	@echo "=== BATCH RUN START $$(date -u +%FT%TZ) (runs dir: $(RUNS_DIRNAME), ceiling: $(READY_CEILING)s) ==="
	@mkdir -p "$(ANALYSIS)"
	@for fw in $(FRAMEWORKS); do \
	  echo ""; \
	  echo "=================================================================="; \
	  echo "FRAMEWORK: $$fw"; \
	  echo "=================================================================="; \
	  $(MAKE) install   FRAMEWORK=$$fw || true; \
	  $(MAKE) wait      FRAMEWORK=$$fw || true; \
	  $(MAKE) probe     FRAMEWORK=$$fw || true; \
	  $(MAKE) score     FRAMEWORK=$$fw || true; \
	  $(MAKE) summary   FRAMEWORK=$$fw || true; \
	  $(PY) "$(HARNESS)/score.py" --framework $$fw --root "$(ROOT)" $(SCORE_ARGS) --append-review-queue || true; \
	  $(MAKE) clean     FRAMEWORK=$$fw || true; \
	  echo "$$fw complete — proceeding."; \
	done
	@$(MAKE) matrix
	@$(PY) "$(HARNESS)/score.py" --end-of-run-report --root "$(ROOT)" $(SCORE_ARGS)
	@echo "=== BATCH RUN END $$(date -u +%FT%TZ) ==="

# v2 entry point: same flow, separate output paths so v1 is never overwritten.
batch-v2:
	@$(MAKE) batch RUNS_DIRNAME=runs_v2 FINDINGS_DIRNAME=findings_v2 \
	               MATRIX_NAME=matrix_v2.csv RQ_NAME=REVIEW_QUEUE_v2.md

matrix:
	@$(PY) "$(HARNESS)/score.py" --matrix --root "$(ROOT)" $(SCORE_ARGS)
	@echo "[matrix] -> $(ANALYSIS)/$(MATRIX_NAME)"
