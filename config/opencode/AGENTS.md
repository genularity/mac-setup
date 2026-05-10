# Global OpenCode Agent Rules

## Versioning

- **All versioned artifacts use the format `YYYY.MM.DD.N`**, where `N` is a build counter starting at 1. This applies universally: FastAPI apps, CLI tools, Python packages, HTML/UI pages, container images, scripts, and any other artifact that carries a version.
- Always use today's date for the date portion — never copy the date from a previous version string or example.
- Increment `N` on every significant commit and every deploy.

## Python

- Always use `uv` for dependency management and running Python tools — never `pip` directly.
- Never install packages globally. Always install into the project virtual environment.
- If a virtual environment does not exist in the project, create one with `uv venv` before proceeding.
- Default to **FastAPI** for web/API projects and **Pydantic** for data validation and settings.
- Always use full type hints on all functions, methods, and class fields.
- Use `ruff` for linting and formatting. Configure it in `pyproject.toml`.
- Use `rich` for all user-facing output, logging, and CLI interaction — console output, progress bars, tracebacks, and log formatting.
- Write `pytest` tests when explicitly asked or when developing reusable modules/libraries. Place tests in a `tests/` directory mirroring the source structure. Use `httpx` and FastAPI's `TestClient` for API tests. Always run tests with `uv run pytest`.
- Never commit `.env` files. Add `.env` to `.gitignore`. Use `pydantic-settings` (`BaseSettings`) for all environment-based configuration.
- When loading environment variables with `load_dotenv`, always load `.env` plus any `.env_*` files present in the same directory:
  ```python
  from dotenv import load_dotenv
  load_dotenv()
  for f in sorted(Path(".").glob(".env_*")):
      load_dotenv(f, override=True)
  ```
- `pydantic-settings` and `typer` are compatible and complement each other — `BaseSettings` handles config from `.env`/environment variables, `Typer` handles CLI argument parsing. Use both together freely.
- When creating a FastAPI app, always set the `version` field using the global `YYYY.MM.DD.N` format (see **Versioning** section). The version must be visible in the OpenAPI docs and reflected in the API title, e.g.:
  ```python
  app = FastAPI(title="My API", version="2026.01.02.3")
  ```
- Default to `async def` for all FastAPI route handlers.
- Never invoke `python`, `python3`, or `py` directly in any context — including inline `-c` one-liners, piped commands, subshells, and heredoc scripts processing local files. Always use `uv run`. Always use `uv add` to add dependencies — never `pip install`.

## Containers

- Always use `podman` instead of `docker` for all container operations. Installed via Homebrew (`/opt/homebrew/bin/podman`) — use `podman` directly as it is on `PATH`.
- Standard deploy flow: `podman build --platform linux/amd64 -t <registry>/<image>:latest .` → `podman push` → `kubectl rollout restart deployment/<name>`.
- **Always chain build + push + rollout as a single `&&` command.** Never issue them as separate tool calls.

## Web UI / HTML

- Every HTML page or UI must include a discreet version stamp in the footer using the global `YYYY.MM.DD.N` format (see **Versioning** section). Keep it small and muted — not prominent. Example:
  ```html
  <footer style="text-align:center; color:#aaa; font-size:0.75rem; padding:1rem;">
    v2026.02.28.1
  </footer>
  ```

## Kubernetes

- Before any deployment or investigation of cluster resources, always check the active context with `kubectx`.
- If there is any doubt about which cluster is targeted, stop and ask the user to confirm before proceeding.

## Agent Verbosity

- Be verbose in output — show reasoning, decisions, intermediate steps, and findings as they work. Do not suppress thinking or summarise only at the end.
- When reporting back to a parent agent or team lead, include everything relevant — all findings, decisions, intermediate results, and confidence levels. Do not compress results to a brief summary.

## Agent Boundaries

- Before operating on any resource (database, API, service, files) that belongs to a directory you were not started in, check that directory for an `AGENTS.md`. If one exists, read it and respect any ownership or access restrictions it defines.

## Agent Teams

- When asked to create an agent team, always use `team_create` first, then spawn teammates using `team_spawn`.
- Do not shut down teammates when they complete their initial tasks. Leave them idle so the user can redirect them to follow-on work. Only shut down when the user explicitly asks.

## Shell Environment

- This machine runs **zsh** as the interactive shell. Containers and k8s pods run **bash**.
- **Never use `status` as a variable name in any shell script or bash command.** It is read-only in zsh and will cause an immediate error. Use `st`, `rc`, or a descriptive name instead. The same applies to other zsh-reserved names: `RANDOM`, `SECONDS`, `LINENO`, `ARGC`, `ARGV`, `OPTARG`, `OPTIND`.
- Do not assume zsh features (arrays, `[[`, `=(...)`, etc.) in scripts that also run inside containers — write POSIX-compatible bash there.

## macOS

- This is a Mac with GNU coreutils, findutils, grep, sed, awk, and tar installed via Homebrew. In interactive use and one-off commands, always use the `g`-prefixed GNU variants — never the BSD macOS defaults. Key examples: `ggrep`, `gsed`, `gawk`, `gfind`, `gxargs`, `gls`, `gdate`, `gstat`, `gdu`, `gwc`, `gsort`, `ghead`, `gtail`, `gcut`, `gtr`, `gtar`, `gcp`, `gmv`, `grm`, `greadlink`, `grealpath`, `gchmod`, `gchown`, `gmkdir`, `gtouch`, `gecho`, `genv`, `gseq`, `guniq`, `gsplit`, `gcomm`, `gjoin`, `gtee`, `gprintf`, `gnumfmt`, `gtimeout`, `gshuf`, `gsync`.
- In shell **scripts** that may run on multiple platforms (e.g. inside a container or k8s pod), do not hardcode `g`-prefixed tools. Resolve them at runtime:
  ```bash
  _tr=tr
  if [[ "$(uname)" == "Darwin" ]]; then
      _tr=$(command -v gtr 2>/dev/null || command -v tr)
  fi
  ```

## Markdown

- Do NOT add frontmatter to `.md` files in git repos.
- Do not use `\n` in Mermaid diagram node labels — use `<br/>` instead.

## Git

- If working in a directory that is not a git repository, flag it — do not initialise without explicit instruction.
- Always create a sensible `.gitignore` when initialising a new repository.
- Default branch is `main`.
- Make sensible, atomic commits with clear messages that describe the intent of the change.
- Do not add the AI assistant as a co-author in commit messages.
- Commit frequently — after each logical unit of work, not just at the end of a task.
- Tag deployments with an annotated tag describing the change, then push: `git tag -a vYYYY.MM.DD.N -m "Description of change" && git push && git push --tags`.

## Secrets

- **Never store credentials, passwords, tokens, API keys, or other secrets in memory files, agent instruction files, or any persisted context.** Credentials belong in `.env` files only.

## Remote Resources

- **All remote resources (APIs, Jenkins, databases, services, repos) are read-only unless the user explicitly instructs otherwise.** Never write, create, update, delete, trigger, or mutate anything on a remote system without explicit instruction.
- When using `curl` or any HTTP client, default to GET/read operations only. Do not use POST, PUT, PATCH, DELETE, or any other mutating verb on remote resources without explicit user approval.
- **Exception — standard deploy pipeline:** When asked to deploy or release, execute the full pipeline without seeking per-step approval: bump the version, commit, annotate-tag, `git push`, `git push --tags`, `podman build`, `podman push`, `kubectl rollout restart`. These steps are pre-authorised as a unit. Always verify `kubectx` before the kubectl step.
