---
name: zyte-fetch
description: Fetch web pages via Zyte API with browser rendering (client-side JavaScript execution). Use when you need to retrieve content from websites that require JavaScript rendering, or when standard web_fetch returns incomplete/empty content due to client-side rendering. Also useful for anti-bot bypass and screenshots.
---

# Zyte Fetch

Fetch web pages through Zyte API. Supports browser-rendered HTML (JavaScript executed), plain HTTP, and screenshots.

## API Key

Stored at `~/.config/zyte/api_key`. Override with `ZYTE_API_KEY_FILE` env var.

## Quick Start

### Browser-rendered HTML (default — handles JS-heavy sites)

```bash
scripts/zyte_fetch.sh "https://example.com"
```

### Plain HTTP (faster, no JS)

```bash
scripts/zyte_fetch.sh "https://example.com" --http
```

### Screenshot

```bash
scripts/zyte_fetch.sh "https://example.com" --screenshot --output page.html
# Saves page.html + page.png
```

### Raw JSON response

```bash
scripts/zyte_fetch.sh "https://example.com" --raw-json
```

## When to Use

- `web_fetch` returns empty/broken content → use `zyte_fetch.sh` (browser mode)
- Site has anti-bot protection → Zyte handles proxy rotation and fingerprinting
- Need a screenshot of a rendered page → use `--screenshot`
- Simple static page → prefer `web_fetch` (free, faster)

## Direct curl (advanced)

```bash
API_KEY=$(cat ~/.config/zyte/api_key)
curl -s --compressed --user "${API_KEY}:" \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com","browserHtml":true}' \
  https://api.zyte.com/v1/extract | jq -r .browserHtml
```

## API Reference

- Endpoint: `POST https://api.zyte.com/v1/extract`
- Auth: Basic auth with API key as username, empty password
- Key request fields:
  - `url` (required): Target URL
  - `browserHtml: true`: Get JS-rendered HTML
  - `httpResponseBody: true`: Get raw HTTP response (base64)
  - `screenshot: true`: Get screenshot (base64 PNG)
- See [full docs](https://docs.zyte.com/zyte-api/usage/reference.html) for geolocation, actions, cookies, sessions, etc.
