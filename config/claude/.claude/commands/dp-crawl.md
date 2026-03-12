---
description: Crawl a website using Cloudflare Browser Rendering and save as markdown
allowed-tools: Bash
---

# Cloudflare Crawl

Crawl a website using the Cloudflare Browser Rendering `/crawl` API and save results as markdown.

Requires `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` env vars. Check `.env`, `.env.local`, and `~/.env` if not set. Token needs "Browser Rendering - Edit" permission.

## Arguments

- First arg: URL to crawl (ask if missing)
- `--limit N`: max pages (default: 10, max: 100,000)
- `--depth N`: max link depth (default: 100,000)
- `--source sitemaps|links|all`: URL discovery method (default: all)
- `--include "pattern1,pattern2"`: only crawl matching URLs
- `--exclude "pattern1,pattern2"`: skip matching URLs (takes priority over include)
- `--no-render`: skip JS rendering (faster, for static sites)
- `--merge`: combine all output into a single file
- `--output DIR`: output directory (default: `.crawl-output`)

## Workflow

1. Load credentials from env or `.env` files
2. POST to `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl` with `url`, `limit`, `formats: ["markdown"]`, and options
3. Response returns `{ "success": true, "result": "<job-id>" }`
4. Poll `GET .../crawl/<JOB_ID>?limit=1` every 5s until status is not `running`
5. Statuses: `running`, `completed`, `cancelled_due_to_timeout`, `cancelled_due_to_limits`, `errored`
6. Fetch records with `?status=completed&limit=50`, paginate using `cursor` field
7. Each record has `url`, `status`, `markdown`, and `metadata` (title, status code)
8. Save each page as markdown to output dir, converting URLs to filenames
9. If `--merge`, concatenate into a single file

## API notes

- `render: true` (default) uses headless browser, `false` does fast HTML fetch (not billed during beta)
- Patterns: `*` matches except `/`, `**` matches including `/`
- Respects robots.txt. Blocked URLs show `"status": "disallowed"`
- Cancel a running job with `DELETE .../crawl/<JOB_ID>`
- Free plan: 10 min browser time/day. Results available 14 days. Max job runtime: 7 days
