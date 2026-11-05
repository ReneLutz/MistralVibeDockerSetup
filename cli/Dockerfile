# Sandboxed Vibe Code CLI (Python package: mistral-vibe, needs Python 3.12+).
# Base image: 24.04 ships Python 3.12, 26.04 ships 3.14 - both satisfy the
# CLI, so install the release default `python3`, never a versioned package
# name (`python3.12` doesn't exist on 26.04).
FROM ubuntu:26.04

ARG UID=1000
ARG GID=1000
# Pin via build arg (.env -> VIBE_VERSION=x.y.z) for reproducible updates.
ARG VIBE_VERSION=

# ca-certificates + curl: TLS + the isolation self-test.
# git: the agent will want it. python3: CLI runtime + your project's scripts.
# Add your project's build deps here (make, gcc, nodejs, ...).
#
# User creation must be IDEMPOTENT: official ubuntu images (24.04+) ship a
# default 'ubuntu' user with UID/GID 1000. On a UID clash we rename that
# user to 'vibe' (home moved to /home/vibe) instead of failing with
# "GID/UID already exists".
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git python3 python3-pip \
 && rm -rf /var/lib/apt/lists/* \
 && EXISTING_GROUP="$(getent group "${GID}" | cut -d: -f1 || true)" \
 && if [ -z "${EXISTING_GROUP}" ]; then groupadd -g "${GID}" vibe; fi \
 && EXISTING_USER="$(getent passwd "${UID}" | cut -d: -f1 || true)" \
 && if [ -n "${EXISTING_USER}" ]; then \
      usermod -l vibe -d /home/vibe -m -g "${GID}" "${EXISTING_USER}"; \
    else \
      useradd -m -u "${UID}" -g "${GID}" -s /bin/bash vibe; \
    fi

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Install system-wide (under /opt) so the $HOME bind mount can't shadow it.
# uv locations are env vars, NOT flags on `tool install` (uv rejects
# --tool-dir there). Correct variable names:
#   UV_TOOL_DIR     -> where uv keeps the tools' virtual environments
#   UV_TOOL_BIN_DIR -> where it symlinks the executables (vibe, vibe-acp)
ENV UV_TOOL_DIR=/opt/uv/tools \
    UV_TOOL_BIN_DIR=/opt/uv/bin
RUN if [ -n "${VIBE_VERSION}" ]; then \
      VIBE_SPEC="mistral-vibe==${VIBE_VERSION}"; \
    else \
      VIBE_SPEC="mistral-vibe"; \
    fi \
 && uv tool install --python /usr/bin/python3 "${VIBE_SPEC}"

ENV PATH="/opt/uv/bin:${PATH}"
USER vibe
WORKDIR /workspace
CMD ["vibe"]
