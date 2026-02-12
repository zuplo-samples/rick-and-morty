# CLAUDE.md

This file provides context for Claude Code and other AI agents working on this repository.

## Project Overview

This is a **Zuplo API gateway** that proxies the [Rick and Morty API](https://rickandmortyapi.com). It serves as a sample project demonstrating Zuplo's features: API key authentication, request proxying, outbound URL rewriting, and the Zudoku developer portal.

## Repository Structure

```
rick-and-morty/
├── config/
│   ├── routes.oas.json     # Main API routes (OpenAPI 3.1 + Zuplo extensions)
│   ├── legacy.oas.json     # Redirects from legacy /docs paths and root to the dev portal
│   └── policies.json       # Inbound/outbound policies (API key auth, URL rewriting)
├── modules/
│   ├── zuplo.runtime.ts    # Runtime extensions (Google Cloud Logging plugin)
│   └── mock.ts             # Custom inbound policy (logging)
├── schemas/                # JSON response schemas (referenced by $ref in routes)
├── docs/                   # Zudoku developer portal (separate npm workspace)
│   ├── zudoku.config.tsx   # Portal configuration (navigation, auth, APIs)
│   ├── pages/              # Markdown documentation pages
│   ├── package.json        # Zudoku dependencies
│   └── tsconfig.json
├── zuplo.jsonc             # Zuplo project manifest
└── package.json            # Root package.json (workspaces: ["docs"])
```

## Key Architecture Decisions

- **The dev portal (Zudoku) runs on a separate domain**, not under `/docs` on the API domain. The `legacyDevPortalHandler` in `config/legacy.oas.json` redirects `/docs(.*)` to the portal's dedicated domain. The root `/` route uses `redirectHandler` to `/docs` first, since `legacyDevPortalHandler` **cannot be used on the root path** (it requires a `/docs` base path).
- **API routes proxy to upstream** using `urlRewriteHandler` with rewrite patterns like `https://rickandmortyapi.com/api/character${search}`.
- **URL rewriting in responses** is handled by the `replace-urls` outbound policy, which rewrites upstream URLs in JSON responses to point back to this gateway.
- **API key authentication** is enforced via the `api-key-inbound` policy on all `/v1/*` routes.
- **The `docs/` folder is a separate npm workspace** using Zudoku (React-based documentation framework). It reads `config/routes.oas.json` to generate interactive API reference docs.

## Commands

```bash
npm install              # Install all dependencies (root + docs workspace)
npm run dev              # Start the Zuplo gateway locally (alias for `zup dev`)
npm run docs             # Start the Zudoku dev portal locally
npx zuplo deploy         # Deploy the gateway to Zuplo
```

## Route Configuration

Routes are OpenAPI 3.1 JSON files under `config/` with Zuplo-specific extensions:

- `x-zuplo-path.pathMode` — `"url-pattern"` (supports `:param`) or `"open-api"`
- `x-zuplo-route.handler` — Request handler (`export`, `module`, `options`)
- `x-zuplo-route.policies` — Named inbound/outbound policies from `policies.json`
- `x-internal: true` — Hides the operation from the public API reference

## Common Handlers

| Handler | Purpose |
|---------|---------|
| `urlRewriteHandler` | Proxy/rewrite requests to upstream. Uses `${params.name}`, `${search}`. |
| `redirectHandler` | HTTP redirect. Options: `location`, `status` (301/302). |
| `legacyDevPortalHandler` | Redirect to the Zudoku dev portal domain. Options: `mode`. **Requires `/docs` base path, cannot be used on root `/`.** |
| `openApiSpecHandler` | Serve the OpenAPI spec file. |

## Policies

Defined in `config/policies.json`:

- `api-key-inbound` — Requires API key authentication on requests
- `replace-urls` — Outbound: rewrites upstream rickandmortyapi.com URLs to this gateway's domain
- `custom-code-inbound` — Custom logging policy (`modules/mock.ts`)

## Environment Variables

- `GCP_SERVICE_ACCOUNT` — Google Cloud service account JSON for logging (used in `modules/zuplo.runtime.ts`)
- `ZUPLO_PUBLIC_AUTH0_DOMAIN` / `ZUPLO_PUBLIC_AUTH0_CLIENT_ID` — Auth0 credentials (can be used in `docs/zudoku.config.tsx`)

## Testing

The API requires an API key. Users can subscribe via the dev portal pricing page using Stripe test cards (e.g., `4242 4242 4242 4242`).
