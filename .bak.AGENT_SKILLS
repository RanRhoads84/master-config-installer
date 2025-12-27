# Agent Skills

This document lists the skills, capabilities, and safe behaviours that automation agents used with this repository should possess.

Core technical skills
- Shell scripting: robust `bash` scripting, `set -euo pipefail`, safe quoting, and careful command construction.
- Git: creating commits, branching, pushing to multiple remotes, handling absent remotes, and composing good commit messages.
- Package managers: familiarity with `apt`, `dnf`, `pacman`, and `zypper` command-line usage and non-interactive flags.
- Debugging: running `bash -x` traces, capturing logs, and diagnosing failures from traces.
- File operations: create/update files, move/rename files, and update `.gitignore` safely.
- Testing: run dry-run modes, hermetic tests using `IGNORE_PKG_DB`, and capture per-run logs and traces.

Operational skills
- Non-interactive defaults: ensure dry-run and CI runs do not block on `read` prompts (use `--yes`/assume-yes behavior).
- Idempotency: make operations safe to re-run without causing duplicate side effects.
- Safety: avoid destructive changes unless explicitly requested; prefer dry-run and explicit user consent.
- Error handling: surface meaningful exit codes and log contextual errors; avoid masking failures silently.
- Timeouts and retries: apply reasonable timeouts and retries for network operations and remote pushes.

Security and privacy
- Secrets handling: never print or commit secrets; use environment variables or secure stores and avoid logging secrets.
- Least privilege: avoid unnecessary `sudo` calls during tests; require explicit consent for privileged operations.

Collaboration & communication
- Clear commits: use conventional, concise commit messages (type(scope): short summary).
- Documentation: update `AGENTS.md`, `AGENT_SKILLS.md`, or repo docs when adding new helper scripts or CI steps.
- Transparency: record test outputs and trace logs in `tests/test_dry_results/` and keep large artifacts gitignored.

Behavioural constraints
- Follow user instructions precisely; ask concise clarifying questions only when required.
- Do not perform network or remote operations without confirming (or when running in dry-run/CI contexts).
- Adhere to repository style and make minimal, focused edits.

Examples of actionable skills
- Construct safe install commands that join package names correctly and use non-interactive flags.
- Implement per-package repo-availability checks and skip missing packages while logging them.
- Implement `--pm` override, `--dry-run`, `--yes` flags and `IGNORE_PKG_DB` test modes.
- Provide helper scripts to push to multiple remotes and handle missing remotes without failing the whole workflow.

If you are writing an agent to operate on this repo, use this file as a minimal checklist before enabling automated pushes or edits.
