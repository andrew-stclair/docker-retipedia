# docker-retipedia

Containerized Retipedia on top of `rns-page-node` for serving `.zim` archives over Reticulum.

## What this image does

- Runs as a non-root user (`uid/gid 10001`)
- Designed to run with a read-only root filesystem
- Uses one writable volume for Reticulum identity + Retipedia runtime data (`zims` metadata, cache, extracted images)
- Uses one read-only bind mount for your `.zim` archives

## Quick start

1. Update the bind mount in `docker-compose.yml`:

   - `/path/to/zim-archives:/zims:ro`

2. Build and start:

   ```bash
   docker compose up --build
   ```

That is enough for first run. The container auto-generates Retipedia metadata sidecars for mounted archives at startup.

## Required mounts

- **Writable volume** for identity and runtime state:
  - `/var/lib/rns-page-node`
- **Read-only bind mount** for `.zim` files:
  - `/zims`

## Reticulum / node configuration

Set environment variables in compose (or `docker run -e ...`) as needed:

- `RETICULUM_CONFIG_DIR` (optional Reticulum config directory)
- `RETICULUM_IDENTITY_DIR` (defaults to `/var/lib/rns-page-node/identity`)
- `RETIPEDIA_NODE_NAME`
- `RETIPEDIA_ANNOUNCE_INTERVAL`
- `RETIPEDIA_PAGE_REFRESH_INTERVAL`
- `RETIPEDIA_FILE_REFRESH_INTERVAL`
- `RETIPEDIA_LOG_LEVEL`

## Retipedia-specific configuration

- `RETIPEDIA_IMAGES=true|false`
- `RETIPEDIA_CHUNK_SIZE`
- `RETIPEDIA_TEXT_LAYOUT` (`center`, `wide`, `narrow`)
- `RETIPEDIA_TEXT_WIDTH`
- `RETIPEDIA_PAGE_CACHE`
- `RETIPEDIA_ACCENT_COLOR` (`default`, `red`, `orange`, `green`)
- `RETIPEDIA_NODE_TITLE`
- `RETIPEDIA_LXMF_ADDRESS`
- `RETIPEDIA_ZIMS_DIR` (defaults to `/zims`)
- `RETIPEDIA_ROOT_FOLDER` (defaults to `Retipedia`)
- `RETIPEDIA_ARCHIVE_PATH` / `RETIPEDIA_ARCHIVE_TYPE` (single-archive fallback)

## Hardening notes

`docker-compose.yml` enables:

- `read_only: true`
- `cap_drop: [ALL]`
- `no-new-privileges:true`
- `tmpfs` for `/tmp`

If you run with `docker run`, use equivalent flags for the same hardening level.
