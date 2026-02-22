# zyte-fetch-skill

A custom skill for [OpenClaw](https://docs.openclaw.ai/) that fetches web pages via the [Zyte API](https://www.zyte.com/) with browser rendering (client-side JavaScript execution).

The built-in `web_fetch` often returns empty or incomplete content from JavaScript-heavy sites. This skill uses Zyte API's browser rendering to retrieve fully rendered pages, making it work reliably with SPAs, JS-dependent sites, and pages behind anti-bot protection.

## Features

- **Browser rendering** — Retrieve HTML after JavaScript execution
- **Anti-bot bypass** — Zyte handles proxy rotation and fingerprinting
- **Screenshots** — Capture rendered pages as PNG
- **HTTP mode** — Fast raw HTTP responses for static pages

## Prerequisites

- A [Zyte API](https://www.zyte.com/) account and API key
- `curl` and `jq` installed
- `base64` command (included by default on macOS / Linux)

## Installation

### 1. Clone the repository

Clone into the OpenClaw managed skills directory:

```bash
git clone https://github.com/jacopen/zyte-fetch-skill.git ~/.openclaw/skills/zyte-fetch-skill
```

Or into a workspace-level skills directory for per-project use:

```bash
git clone https://github.com/jacopen/zyte-fetch-skill.git ./skills/zyte-fetch-skill
```

### 2. Set up the Zyte API key

```bash
mkdir -p ~/.config/zyte
echo "YOUR_ZYTE_API_KEY" > ~/.config/zyte/api_key
chmod 600 ~/.config/zyte/api_key
```

You can override the key file path with the `ZYTE_API_KEY_FILE` environment variable:

```bash
export ZYTE_API_KEY_FILE=/path/to/your/api_key
```

### 3. Enable the skill in OpenClaw

Add the following to your `openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "zyte-fetch": {
        "enabled": true
      }
    }
  }
}
```

Changes take effect on the next new session.

## Usage

### Within OpenClaw

Once installed, OpenClaw will automatically recognize the skill and use it when fetching web pages. It is especially useful when:

- `web_fetch` returns empty or incomplete content
- The target site requires JavaScript rendering
- The site has anti-bot protection
- You need a screenshot of a rendered page

### Standalone script

`scripts/zyte_fetch.sh` can also be used independently.

#### Browser-rendered HTML (default)

Fetches the page with JavaScript executed:

```bash
scripts/zyte_fetch.sh "https://example.com"
```

#### HTTP mode

Faster fetch for static pages (no JS execution):

```bash
scripts/zyte_fetch.sh "https://example.com" --http
```

#### Screenshot

Saves both the rendered HTML and a PNG screenshot:

```bash
scripts/zyte_fetch.sh "https://example.com" --screenshot --output page.html
# Outputs page.html and page.png
```

#### Raw JSON response

Outputs the raw Zyte API JSON response:

```bash
scripts/zyte_fetch.sh "https://example.com" --raw-json
```

### Options

| Option | Description |
|---|---|
| `--http` | Use HTTP mode instead of browser rendering (faster, no JS) |
| `--screenshot` | Save a PNG screenshot of the rendered page |
| `--output FILE` | Write output to a file instead of stdout |
| `--raw-json` | Output the raw Zyte API JSON response |

## When to use this vs. web_fetch

| Scenario | Recommended tool |
|---|---|
| Static HTML page | `web_fetch` (free, faster) |
| JS-rendered site | `zyte_fetch` (browser mode) |
| `web_fetch` returns empty/broken content | `zyte_fetch` (browser mode) |
| Site with anti-bot protection | `zyte_fetch` |
| Need a screenshot | `zyte_fetch --screenshot` |

## License

[MIT License](LICENSE)
