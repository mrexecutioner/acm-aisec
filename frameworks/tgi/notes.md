# Hugging Face TGI - notes

## Source
- Quicktour: https://huggingface.co/docs/text-generation-inference/quicktour
- Reference: https://huggingface.co/docs/text-generation-inference/reference/api_reference
- URL captured: 2026-05-30. **Human verifies content at pre-batch gate.**

## Ship-as-default posture (claimed, to be verified by probes)
- Bind: 0.0.0.0:80 inside container (mapped to host 8080).
- Auth: none by default; basic-auth and JWT options exist via reverse proxy / env.
- No model push/pull/delete; model fixed at launch via `--model-id`.

## Platform caveat + v4 CPU decision
- The GPU image requires NVIDIA CUDA with kernels for the host GPU. On the RTX 5090
  Laptop (Blackwell, sm_120) TGI's prebuilt CUDA kernels are missing
  (`Unkown compute for card nvidia-geforce-rtx-5090-laptop-gpu`) → shard crash-loop
  → unmeasurable (v2/v3).
- **v4 measures TGI via its CPU image** `ghcr.io/huggingface/text-generation-inference:latest-intel-cpu`
  (CPU/Intel build documented at the TGI installation docs:
  https://huggingface.co/docs/text-generation-inference/installation_intel and the
  GHCR package tags, checked 2026-05-31). Model: gpt2 (smallest practical).
- **Justification for the mixed environment (Threats to Validity):** the checklist
  measures *security defaults*, default bind address, whether auth is required,
  unauthenticated management endpoints, root-by-default container, default rate
  limiting. These are properties of the server's configuration and packaging, NOT
  of the inference compute backend. CPU vs GPU changes inference latency, not the
  auth/network/privilege posture. So measuring TGI on CPU yields a valid
  security-defaults row that is directly comparable to the GPU-served frameworks.
  The human has chosen to keep the other frameworks on GPU and accept this one
  documented CPU substitution rather than unify everything to CPU.

## Items requiring human read
- D6.1 - TGI does emit Prometheus metrics; check whether anything else egresses.
- D7.1 - quicktour leads with `docker run -p 8080:80` (LAN-exposed) - is that secure-by-default?
