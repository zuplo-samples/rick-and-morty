# AGENTS.md

This file provides context for AI coding agents (OpenAI Codex, etc.) working on this repository.

## Project Overview

A **Zuplo API gateway** proxying the [Rick and Morty API](https://rickandmortyapi.com). Demonstrates API key authentication, request proxying, URL rewriting, and the Zudoku developer portal.

## Structure

```
config/routes.oas.json   — Main API routes (OpenAPI 3.1 + Zuplo x- extensions)
config/legacy.oas.json   — Root and /docs redirects to the dev portal domain
config/policies.json     — Inbound/outbound policies (API key auth, URL rewriting)
modules/                 — Custom TypeScript handlers and policies
schemas/                 — JSON response schemas ($ref'd from routes)
docs/                    — Zudoku developer portal (separate npm workspace)
docs/zudoku.config.tsx   — Portal config (navigation, auth, API reference)
docs/pages/              — Markdown documentation pages
zuplo.jsonc              — Zuplo project manifest
```

## Important: Dev Portal Architecture

The Zudoku dev portal runs on its **own dedicated domain**, NOT under `/docs` on the API domain. The `legacyDevPortalHandler` in `config/legacy.oas.json` handles redirects from `/docs(.*)` to the portal. The root `/` route uses `redirectHandler` to `/docs` first, since `legacyDevPortalHandler` **cannot be used on the root path** (requires a `/docs` base path).

## Commands

```bash
npm install              # Install all deps (root + docs workspace)
npm run dev              # Start Zuplo gateway locally
npm run docs             # Start Zudoku dev portal locally
npx zuplo deploy         # Deploy to Zuplo
```

## Route Conventions

- Routes are in `config/*.oas.json` (OpenAPI 3.1 with `x-zuplo-route` extensions)
- Handlers: `urlRewriteHandler` (proxy), `redirectHandler` (HTTP redirect), `legacyDevPortalHandler` (portal redirect, requires `/docs` base path — cannot be used on root `/`), `openApiSpecHandler` (serve spec)
- Policies are defined in `config/policies.json` and referenced by name in routes
- Set `"x-internal": true` to hide operations from the public API docs
- Path params use `:paramName` syntax with `pathMode: "url-pattern"`

## Policies

- `api-key-inbound` — API key auth (required on all `/v1/*` routes)
- `replace-urls` — Rewrites upstream URLs in responses to this gateway's domain
- `custom-code-inbound` — Custom logging policy (`modules/mock.ts`)

## Environment Variables

- `GCP_SERVICE_ACCOUNT` — Google Cloud Logging service account
- Auth0 credentials for the dev portal (`ZUPLO_PUBLIC_AUTH0_DOMAIN`, `ZUPLO_PUBLIC_AUTH0_CLIENT_ID`)
