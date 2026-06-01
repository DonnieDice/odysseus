# <img src="./docs/icon.png" alt="Odysseus" width="28" height="28"> Odysseus
───────────────────────────────────────────────

Odysseus vers. 1.0
⊹ ࣪ ˖ ૮( ˶ᵔ ᵕ ᵔ˶ )っ

───────────────────────────────────────────────

[![License: MIT](https://img.shields.io/badge/license-MIT-4a5568.svg)](LICENSE)
[![Python 3.11+](https://img.shields.io/badge/python-3.11%2B-2b6cb0.svg)](pyproject.toml)
[![JavaScript](https://img.shields.io/badge/javascript-ES2023-b7791f.svg)](static/)
[![Docker](https://img.shields.io/badge/docker-ready-2c7a7b.svg)](Dockerfile)

![Odysseus](docs/odysseus.jpg)

A self-hosted AI workspace -- meant to be the self-hosted version of the UI experience you get from ChatGPT and Claude. But with more jank and fun. Running on your own hardware, with your own data -- local-first, privacy-first, and no trojan.

## Features
| Area | What it does | Integrations |
|---|---|---|
| Chat | Chat with local models or hosted APIs. | vLLM, llama.cpp, Ollama, OpenRouter, OpenAI |
| Agent | Give the assistant tools and let it work through tasks. | opencode, MCP, web, files, shell, skills, memory |
| Cookbook | Scan hardware, choose models, download them, and launch serving. | llmfit, GGUF, FP8, AWQ, vLLM, llama.cpp |
| Deep Research | Gather sources, read them, and synthesize a visual report. | Adapted from Tongyi DeepResearch |
| Compare | Blind side-by-side model comparison and synthesis. | Multi-model judging, hidden labels |
| Documents | Write first, with AI available for edits and suggestions. | Markdown, HTML, CSV, syntax highlighting |
| Memory / Skills | Persistent context, skills, and retrieval for agent workflows. | ChromaDB, fastembed, vector and keyword retrieval |
| Email | IMAP/SMTP inbox with triage, summaries, tags, and reply drafts. | IMAP, SMTP, per-account routing |
| Notes & Tasks | Notes, reminders, to-dos, and scheduled agent tasks. | ntfy, browser notifications, email channels |
| Calendar | Local-first calendar with CalDAV sync. | Radicale, Nextcloud, Apple, Fastmail |
| Mobile | Responsive, touch-friendly app experience. | PWA install, touch gestures |
| Extras | Tools for media, search, presets, sessions, and account security. | Image editor, theme editor, uploads, web search, 2FA |

## Demo
A full, hover-to-play tour lives on the landing page (`docs/index.html`).

<details>
<summary>Screenshots / clips</summary>

### Chat & Agents
<p align="center">
  <img src="docs/chat.gif" alt="Chat & Agents">
</p>

### Deep Research
<p align="center">
  <img src="docs/research.gif" alt="Deep Research">
</p>

### Compare
<p align="center">
  <img src="docs/compare.gif" alt="Compare">
</p>

### Documents
<p align="center">
  <img src="docs/document.gif" alt="Documents">
</p>

### Notes & Tasks
<p align="center">
  <img src="docs/notes.gif" alt="Notes & Tasks">
</p>

</details>

## Quick Start

Defaults work out of the box: clone, run, then configure models/search/email
inside **Settings**. Only edit `.env` for deployment-level overrides like
`APP_PORT`, `AUTH_ENABLED`, `DATABASE_URL`, or a pre-seeded admin password.

Contributing? See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for setup, testing, and
pull request guidelines.

### Docker (recommended)
```bash
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
cp .env.example .env       # optional, but recommended for explicit defaults
docker compose up -d --build
```
Open `http://localhost:7000` when the containers are healthy. If the port is
taken, set `APP_PORT=7001` in `.env` and recreate the container.

### Native Linux / macOS
```bash
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python setup.py
python -m uvicorn app:app --host 0.0.0.0 --port 7000
```
Requirements: Python 3.11+. Cookbook also needs `tmux` for background model
downloads and serves.

### Apple Silicon
Docker on macOS cannot use the Metal GPU. For GPU-accelerated Cookbook on an
M-series Mac, run Odysseus natively:

```bash
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
./start-macos.sh
```

It launches at `http://127.0.0.1:7860`. To build a clickable app wrapper:

```bash
./build-macos-app.sh
```

<details>
<summary>Cookbook, GPU, Ollama, and troubleshooting notes</summary>

**Docker bundled services.** Compose starts Odysseus, ChromaDB, SearXNG, and
ntfy. ChromaDB/SearXNG/ntfy bind host ports to `127.0.0.1` by default, so they
are reachable from the host but not exposed to your LAN/public internet unless
you opt in.

**Cookbook storage in Docker.** Downloads live in `./data/huggingface`
(`~/.cache/huggingface` in the container). Cookbook-installed Python CLIs and
serve engines live in `./data/local` (`~/.local` in the container), so they
survive container recreation.

**Remote servers.** In **Cookbook -> Settings -> Servers**, generate the
Odysseus SSH key and add the public key to the remote server's
`~/.ssh/authorized_keys`. From the host you can also run:

```bash
ssh-copy-id -i data/ssh/id_ed25519.pub user@server
```

**NVIDIA / AMD Docker GPU overlays.** Install the host runtime first, then add
one of these to `.env`:

```bash
COMPOSE_FILE=docker-compose.yml:docker/gpu.nvidia.yml
COMPOSE_FILE=docker-compose.yml:docker/gpu.amd.yml
```

Verify with:

```bash
docker compose exec odysseus nvidia-smi -L
docker compose exec odysseus rocm-smi
```

**Ollama with Docker.** If Ollama runs on the host, add this endpoint in
Settings:

```text
http://host.docker.internal:11434/v1
```

Ollama must listen outside its own loopback interface:

```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

**Useful checks.**

```bash
docker compose ps
docker compose logs --tail=120 odysseus
docker compose logs odysseus | grep -E 'ChromaDB|MemoryVectorStore|DEGRADED'
```

**macOS details.** `start-macos.sh` installs Homebrew deps, creates the venv,
runs setup, and starts uvicorn on port `7860` because AirPlay often holds
`7000`. It uses llama.cpp/Ollama for Metal. vLLM/SGLang are CUDA/ROCm-only and
do not run on macOS. MLX-only models are not served by Odysseus.

</details>

### Native Windows

**One-command launcher** (creates the venv, installs deps, runs setup, starts the
server; safe to re-run):

```powershell
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
powershell -ExecutionPolicy Bypass -File .\launch-windows.ps1
```

Or do it by hand:

```powershell
git clone https://github.com/pewdiepie-archdaemon/odysseus.git
cd odysseus
python -m venv venv
venv\Scripts\Activate.ps1
pip install -r requirements.txt
python setup.py
python -m uvicorn app:app --host 127.0.0.1 --port 7000
```

**Requirements:** Python 3.11+. The core app (chat, agent, memory, documents,
email, calendar, deep research) runs fully native. For full **Cookbook** background
model downloads and the agent shell tool, also install
[Git for Windows](https://git-scm.com/download/win) (provides `bash.exe`).
Local GPU *serving* of vLLM/SGLang needs Linux/WSL2; for a local model on Windows,
[Ollama](https://ollama.com/download) is the easiest path — point Odysseus at
`http://localhost:11434/v1` in Settings.

Open `http://localhost:7000`, log in with the generated admin password,
and configure everything else inside **Settings**.

## Security Notes
Odysseus is a self-hosted workspace with powerful local tools: shell access, file uploads, model downloads, web research, email/calendar integrations, and API tokens. Treat it like an admin console.

- Keep `AUTH_ENABLED=true` for any network-accessible deployment.
- Do not expose it directly to the public internet without HTTPS and a trusted reverse proxy.
- Keep `data/`, `.env`, logs, databases, and uploaded/generated media out of Git. They are ignored by default.
- Review `data/auth.json` after first boot: disable open signup unless you intentionally want it, make only your own account admin, and keep demo/test accounts non-admin.
- Non-admin users do not get shell/Python/file read/write by default, and admin-only routes/tools such as MCP management, API tokens, webhooks, model/cookbook serving, backup/vault, and app settings are admin-gated. Other features are controlled by per-user privileges, so review each user's privileges before exposing a deployment.
- Rotate any API keys or tokens that were ever pasted into a shared chat, demo, screenshot, or log.
- If you enable API tokens or webhooks, create separate tokens per integration and delete unused ones.
- Prefer binding manual development runs to `127.0.0.1`; bind to `0.0.0.0` only when you intentionally want LAN/reverse-proxy access.
- Before publishing a fork, run `git status --short` and confirm no private files from `.env`, `data/`, `logs/`, uploads, backups, or local databases are staged.

### Putting it behind HTTPS
Odysseus serves plain HTTP on its port. That's fine for `localhost` and trusted LAN/VPN use, but browsers will warn ("Password fields present on an insecure page") and the login + API tokens travel in cleartext. For anything reachable outside your machine — including a Tailscale IP shared with other devices — put a TLS-terminating reverse proxy in front.

Shortest path with [Caddy](https://caddyserver.com/) (auto-renews Let's Encrypt certs):

```caddy
odysseus.example.com {
  reverse_proxy localhost:7000
}
```

For a LAN-only Tailscale deployment, Caddy + [tailscale-cert](https://caddyserver.com/docs/caddyfile/options#auto-https) or the built-in MagicDNS HTTPS feature both work. nginx/Traefik configs are similar — proxy `localhost:7000`, terminate TLS at the proxy. Once that's in place, the browser warning goes away and your login is encrypted.

## Contributing
Help is welcome. The best entry points are fresh-install testing, provider setup
bugs, mobile/editor polish, docs, and small focused refactors. See
[docs/ROADMAP.md](docs/ROADMAP.md) for the current help-wanted list.

## Configuration
Most setup is done inside the app with `/setup` or **Settings**. Use `.env`
for deployment-level defaults and secrets you want present before first boot.
Key settings:

| Variable | Default | Description |
|---|---|---|
| `LLM_HOST` | `localhost` | Your LLM server (e.g. `llm-host.local:8000`) |
| `LLM_HOSTS` | -- | Comma-separated list for model discovery |
| `OPENAI_API_KEY` | -- | Optional OpenAI key. Prefer adding providers in the app unless pre-seeding. |
| `SEARXNG_INSTANCE` | `http://localhost:8080` | SearXNG URL. Docker overrides this to `http://searxng:8080`. |
| `SEARXNG_SECRET` | generated on first Docker boot | Optional SearXNG cookie/CSRF secret. Leave blank unless you need to pin it. |
| `AUTH_ENABLED` | `true` | Enable/disable login |
| `LOCALHOST_BYPASS` | `false` | Development-only auth bypass for loopback requests. Keep false for shared/network deployments. |
| `DATABASE_URL` | `sqlite:///./data/app.db` | Database connection string |
| `CHROMADB_HOST` | `localhost` | ChromaDB host for vector memory. Docker overrides this to `chromadb`. |
| `CHROMADB_PORT` | `8100` | ChromaDB port for manual host runs. Docker overrides this to `8000`. |
| `EMBEDDING_URL` | -- | OpenAI-compatible embeddings endpoint |

### Built-in MCP servers (optional setup)

Odysseus auto-registers a few built-in MCP servers at startup. The npx-based ones (currently the browser server, `@playwright/mcp`) only start when their npm package is already in the local npx cache. If a package isn't cached, that server is skipped with a startup log message explaining what to do, so a fresh install does not block on a multi-minute npm download or hang if Playwright system deps are missing.

To enable the browser MCP (page navigation, screenshots, vision), run once:

```bash
npx -y @playwright/mcp@latest --version
```

That installs `@playwright/mcp` plus Playwright (~300MB total). Restart Odysseus and the server will register at startup.

## Architecture
```
app.py                   # FastAPI entry point
core/      auth, database, middleware, constants
src/       llm_core, agent_loop, agent_tools, chat_processor, search/
routes/    chat, session, document, memory, model … endpoints
services/  docs, memory, search, hwfit (Cookbook) …
static/    index.html + app.js + style.css + js/ (modular front-end)
docs/      landing page (index.html) + preview clips
```

## Data
All user data lives in `data/` (gitignored): `app.db` (sessions, messages, documents),
`memory.json`, `presets.json`, `uploads/`, `personal_docs/`, `chroma/`, `settings.json`.

## Star History

<a href="https://www.star-history.com/?repos=pewdiepie-archdaemon%2Fodysseus&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=pewdiepie-archdaemon/odysseus&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=pewdiepie-archdaemon/odysseus&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=pewdiepie-archdaemon/odysseus&type=date&legend=top-left" />
 </picture>
</a>

## License
MIT -- see [LICENSE](LICENSE), [docs/LICENSE.md](docs/LICENSE.md), and
[docs/ACKNOWLEDGMENTS.md](docs/ACKNOWLEDGMENTS.md).

```
                                  |
                                 |||
                                |||||
                  |    |    |   |||||||
                 )_)  )_)  )_)   ~|~
                )___))___))___)\  |
               )____)____)_____)\\|
             _____|____|____|_____\\\__
             \                       /
       ~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~
               ~^~  all aboard!  ~^~
       ~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~~^~^~
```
