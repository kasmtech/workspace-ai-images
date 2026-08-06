# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Dockerfiles and shell-based install scripts that build Kasm Workspaces container images for AI workloads (Claude Code, Codex CLI, Cursor, Gemini CLI, AnythingLLM, PyTorch/TensorFlow/CUDA desktops, ML engineering tools, etc.). There is no application code to compile — the "build" is `docker build`, and the "test" is a full Kasm Workspaces deployment exercised by a CI-only test harness. Everything runs in GitLab CI; there is no GitHub remote (`gh` is not applicable here, use the `dev-helper` MCP for GitLab/Jira).

## Repository layout

- `dockerfile-kasm-*` (repo root) — one Dockerfile per published image. Each `FROM kasmweb/<base>:$BASE_TAG` (bases like `core-ubuntu-jammy`, `core-ubuntu-noble`, `ubuntu-noble-nvidia` are themselves Kasm images built elsewhere/upstream).
- `src/ubuntu/install/<component>/install_<component>.sh` — one install script per component (chrome, vs_code, claude_code, codex, gemini, cursor, cuda, pyenv, ollama, anythingllm, tools, cleanup, ...). Dockerfiles reference these by path.
- `src/ubuntu/config/custom_startup/` — startup script fragments (`start_custom_startup.fragment`, `end_custom_startup.fragment`) that get concatenated into `$STARTUPDIR/custom_startup.sh` inside the image.
- `src/ubuntu/install/main_install.sh` / `prep.sh` — generic drivers used by some newer/refactored images to install a comma-separated `IMAGE_ITEMS` list rather than hardcoding a shell loop in the Dockerfile (see "Two Dockerfile patterns" below).
- `ci-scripts/` — all CI orchestration (see below).
- `docs/<image>/README.md` (+ `description.txt`, `demo.txt`) — per-image Docker Hub description content, synced by CI via `readme.sh`.
- `GPU_SETUP.md` — host-level NVIDIA driver / Container Toolkit setup instructions for GPU-accelerated workspaces (not part of the image build itself).
- `squid/` + `dockerfile-kasm-squid-cache` — a Squid caching proxy image (currently commented out of `template-vars.yaml`, i.e. not built by CI).

## Two Dockerfile patterns

Look at an existing Dockerfile for the image family you're touching before adding a new one — they follow one of two styles:

1. **Loop-based** (e.g. `dockerfile-kasm-claude-code`, `dockerfile-kasm-ubuntu-jammy-desktop-ai-dev`): sets `INST_SCRIPTS` to a space-separated list of `install_*.sh` paths, `COPY`s all of `./src/` in one layer, then loops `for SCRIPT in $INST_SCRIPTS; do bash ...; done` in a single `RUN`. Simple, but any change to any script invalidates the single big layer.
2. **Per-component layer** (e.g. `dockerfile-kasm-ubuntu-anythingllm`): `COPY`s and `RUN`s each component individually (`COPY ./src/ubuntu/install/chrome ... && RUN bash .../install_chrome.sh && rm -rf ...`), giving one Docker layer per component for better caching. Uses `main_install.sh`/`prep.sh` conventions in some cases.

Both patterns end with `set_user_permission.sh`, fixing ownership to `1000:0`, creating `/home/kasm-user`, switching `USER 1000`, and running as the unprivileged `kasm-user`.

## Adding or modifying a component

1. Add/edit `src/ubuntu/install/<component>/install_<component>.sh`. Keep cleanup (`apt-get autoclean`, clearing `/var/lib/apt/lists/*`, `/tmp/*`) at the end, guarded by `if [ -z ${SKIP_CLEAN+x} ]`.
2. Reference the script from the relevant `dockerfile-kasm-*` file(s), following whichever pattern that Dockerfile already uses.
3. Add the component's file globs to that image's `changeFiles` list in `ci-scripts/template-vars.yaml` — CI only rebuilds an image when files matching its `changeFiles` (or the universal `files` list) changed, so a missing entry means your change silently won't trigger a rebuild on non-`develop`/non-`release` branches.
4. If the image is new, add an entry to `ci-scripts/template-vars.yaml` under `multiImages` (needs multi-arch x86_64/aarch64 build+test) or `singleImages` (x86_64 only), with `name`, `base`, `dockerfile`, and `changeFiles`.
5. If the image should have Docker Hub documentation, add `docs/<name>/README.md`, `description.txt`, and optionally `demo.txt`.

## CI pipeline (GitLab)

`.gitlab-ci.yml` is itself generated: the `template` stage runs `ci-scripts/template-gitlab.py`, which renders `ci-scripts/gitlab-ci.template` (Jinja2) using `ci-scripts/template-vars.yaml`, producing the real child pipeline `gitlab-ci.yml` that gets triggered. **To change pipeline structure/stages, edit `gitlab-ci.template`; to add/remove images or their trigger paths, edit `template-vars.yaml`.**

Per-image stages generated from the template: `build` → `test` → `manifest` (plus `readme` and `revert` helper jobs, and a scheduled `weekly_manifest`):

- **build** (`ci-scripts/build.sh`) — `docker build` + push to a private per-pipeline cache tag (`image-cache-private:<arch>-<name>-<branch>-<pipeline_id>`).
- **test** (`ci-scripts/test.sh`) — spins up a real EC2 instance per architecture, installs a Kasm Workspaces release build on it, deploys the just-built image, and runs `kasmweb/kasm-tester` against it end-to-end. Status is read back from an S3-hosted `ci-status.yml`. `skiptest: true` in `template-vars.yaml` bypasses this (always "passes").
- **manifest** (`ci-scripts/manifest.sh`) — on test pass, pulls the cached image, tags/pushes to the public (or `-private`, for non-`develop`/`release` branches) repo, and for multi-arch images creates/pushes a manifest list.
- File-change filtering (`FILE_LIMITS`) is skipped entirely on `develop`, `release/*` branches, scheduled pipelines, or when `USE_PRIVATE_IMAGES` is set — those always build everything.

There is no local build/test/lint command beyond plain `docker build -f <dockerfile> .` — CI (or a self-hosted runner with `oci-amd-scheduled`/`oci-arm-scheduled` tags) is required for the real test stage since it provisions AWS EC2 and a full Kasm deployment.

## Conventions

- All install scripts run as `root` inside the image build; the image itself runs as UID `1000` (`kasm-user`) at runtime.
- `$STARTUPDIR` is `/dockerstartup`, `$HOME` during build is `/home/kasm-default-profile` and becomes `/home/kasm-user` at runtime — install scripts that write user config need to account for this switch.
- Cleanup at the end of an install script should be skippable via `SKIP_CLEAN` so multi-script Dockerfiles can defer cleanup to the last step.
- Custom startup behavior (things that must run once per container start, not once at build time) goes into `custom_startup.sh` fragments under `_config/custom_startup/` or a component's own `custom_startup.sh`, concatenated at build time.
