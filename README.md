# wa-mirror plugin

Claude plugin and marketplace for **wa-mirror**: a macOS-only tool that mirrors the official
WhatsApp desktop app's local database read-only into a local SQLite, builds an exact "waiting on you"
list for direct chats, verifies evidence-backed review items for groups, and serves them to Claude
through a thin MCP adapter. It never connects to WhatsApp or Meta and never sends a message.

This repository holds only the plugin (manifest, launcher, skills). The engine lives in a separate
repository that must be installed locally first:

1. Clone the wa-mirror engine repository and run `uv sync --frozen`, then `uv run wamirror init`.
   `init` writes `~/Library/Application Support/wa-mirror/repo_path`, which the launcher reads.
2. Add this repository as a plugin marketplace in Claude (Customize → Plugins → add marketplace).
3. Enable the `wa-mirror` plugin. The MCP server runs locally through the desktop app.

Everything stays on your Mac. The plugin reads one file from the data directory (`repo_path`) and
starts `wamirror serve` from the engine checkout.
