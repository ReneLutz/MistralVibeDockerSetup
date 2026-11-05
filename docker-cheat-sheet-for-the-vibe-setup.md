# Docker cheat sheet for the Vibe setup

Commands you'll actually need around the Vibe CLI containers. Two compose projects live in `~/vibe-docker`: `vibe` (restricted profile) and `vibe-open` (unrestricted profile) — commands targeting the open profile need `-f docker-compose.open.yml`.

## Everyday workflow

```bash
# In ~/vibe-docker:
docker compose build                                # rebuild restricted (images: vibe-cli, vibe-proxy)
docker compose -f docker-compose.open.yml build     # rebuild open (image: vibe-open-cli)
./verify-isolation.sh                               # re-prove the sandbox after every rebuild

# In your project directory:
vibe            # restricted session (Mistral-only egress)
vibe-open       # unrestricted session
```

## Images

```bash
docker images                      # list; old builds appear as <none>:<none> ("dangling")
docker image prune -f              # delete dangling images - the usual post-rebuild cleanup
docker rmi vibe-cli                # delete a specific image
docker image inspect vibe-cli      # full metadata: layers, env, entrypoint
docker image history vibe-cli      # layer by layer, what each build step produced
```

## Containers

```bash
docker ps                          # running containers
docker ps -a                       # everything, incl. stopped (e.g. vibe-proxy-1 between sessions)
docker rm <name-or-id>             # remove one stopped container
docker container prune -f          # remove ALL stopped containers
docker rename <old> <new>          # rename a container
```

## Debugging

```bash
docker logs -f vibe-proxy-1                        # follow stdout/stderr of a container
docker exec -it vibe-proxy-1 bash                  # shell into a running container
docker exec vibe-proxy-1 tail -f /var/log/squid/access.log   # the egress audit trail
docker stats                                       # live CPU/mem/net per container
docker inspect vibe-proxy-1                        # full runtime config (IPs, mounts, env)
```

## Compose

```bash
docker compose ps -a                       # this project's containers, incl. stopped
docker compose logs -f [service]           # follow one service (services: cli, proxy)
docker compose up -d proxy                 # start one service in the background
docker compose stop proxy                  # stop it (container survives; next start is fast)
docker compose down                       # remove this project's containers + networks
docker compose down --rmi all             # ... and its built images
docker compose build [service]            # rebuild; add --no-cache to start from scratch
docker compose up -d --force-recreate      # recreate after an image or config changed
```

Open profile: prefix every command with `-f docker-compose.open.yml`. That's a separate project (`vibe-open`), so `docker compose down` in one profile leaves the other alone.

## Spring cleaning

```bash
docker system df                          # how much disk Docker is eating (run this first)
docker system prune -f                    # stopped containers + dangling images + unused networks
docker system prune -af --volumes         # EVERYTHING unused, incl. volumes - read before firing:
                                          #   kills the stopped proxy and any named volume
                                          #   (vibe config survives: it's in ./home, a bind mount)
```

## WSL2 specifics

```bash
systemctl status docker            # daemon lives inside your distro (systemd)
sudo systemctl disable docker      # don't even start the daemon at distro boot
docker context ls                  # confirm you're on the native engine, not Docker Desktop
```

From Windows PowerShell: `wsl --shutdown` hard-stops every distro including the Docker daemon; `wsl -d <distro>` starts it again. Nothing comes back up on its own — the wrappers start what they need.

## Why the names look the way they do

| Object | Pattern | Example |
|---|---|---|
| Image from `build:` | `<project>-<service>` | `vibe` + `cli` → `vibe-cli` |
| Container from `up` | `<project>_<service>_N` | `vibe_proxy_1` |
| Container from `run` | generated name | created and removed per session (`--rm`) |

Two gotchas worth remembering:

- `docker compose run` **replaces** the service command with whatever you pass — that's why the wrappers re-state `vibe` before `"$@"`.
- `docker compose run` ignores `ports:` unless you pass `--service-ports` (irrelevant here — nothing is published by design).