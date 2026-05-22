# Rust Cursor Agent Foundation

## Executive Summary

This repository provides a **Cursor-native AI agent development foundation** for Rust UI applications built with [Slint](https://slint.dev/). It implements the architectural recommendations from the Rust AI Agent Development Foundation report:

- **Cargo workspace** with SOLID boundaries (`core_domain`, `infrastructure`, `ui_application`)
- **Strict lint guardrails** that force agents to write production-grade Rust
- **10 project-scoped Cursor skills** using the Brain-Tool-Context triad (SKILL.md + scripts/ + references/)
- **RPI workflow** (Research → Plan → Implement) with persistent planning docs
- **Multi-agent validation** pipeline (Executor / Validator / Critic)
- **Context survival hooks** that preserve session state across compaction

Open this project in Cursor to get rules, skills, hooks, and prompts automatically loaded.

## Installation

### Prerequisites

- Rust toolchain (1.75+): [rustup.rs](https://rustup.rs/)
- Linux system libraries for Slint/winit (Wayland or X11):
  ```bash
  # Debian/Ubuntu
  sudo apt install libxkbcommon-dev libfontconfig1-dev
  ```
- Python 3 (for JSON scripts)
- Optional: `cargo-audit` for security skill (`cargo install cargo-audit`)
- Optional: [agent-browser](https://github.com/vercel-labs/agent-browser) for headless UI validation (set `AGENT_BROWSER_URL` for wasm/web targets)
- Optional: Rust nightly for JSON test output (`rustup install nightly`)

### Setup

```bash
git clone <repo-url> rust_tools
cd rust_tools
cargo check --workspace
./scripts/lint_and_fmt.sh
```

## Usage

### RPI Workflow

1. **Research** — Use `@rpi-research` or `.cursor/prompts/01-research.md`. Output goes to `docs/planning_docs/implementation_research.md`. No code edits.

2. **Plan** — Use `.cursor/prompts/02-plan.md`. Create `docs/planning_docs/implementation_plan.md`. Get approval before coding.

3. **Implement** — Use `@rpi-implement` with `.cursor/prompts/03-implement-step.md`. One atomic step at a time.

4. **Review** — Run `./scripts/orchestrate_review.sh`. Critic review via `@adversarial-review` in a fresh session.

### Quality Commands

```bash
./scripts/lint_and_fmt.sh       # Format + Clippy
./scripts/test_json.sh          # Tests with JSON output
./scripts/quality_gate.sh       # Full validation gate
./scripts/orchestrate_review.sh # Validator + Critic (required before merge)
```

### Running the UI

```bash
cargo run -p ui_application
```

### Invoking Skills

Reference skills in Cursor chat:

- `@rust-core` — new Rust modules and domain logic
- `@rust-lint-hunter` — fix compiler/Clippy errors
- `@slint-ui-component` — Slint layout and components
- `@adversarial-review` — Critic code review

See [AGENTS.md](AGENTS.md) for the full skill roster and multi-agent roles.

### Project Structure

```
rust_tools/
├── core_domain/          # Pure business logic
├── infrastructure/       # Storage adapters
├── ui_application/       # Slint UI
├── .cursor/
│   ├── rules/            # Agent behavioral rules
│   ├── skills/           # 10 agent skills
│   ├── prompts/          # RPI reusable prompts
│   └── hooks/            # Context survival hooks
├── docs/planning_docs/   # RPI persistent memory
└── scripts/              # Validation and orchestration
```

Developer documentation for sub-reports and planning workflow: [docs/planning_docs/README.md](docs/planning_docs/README.md).
