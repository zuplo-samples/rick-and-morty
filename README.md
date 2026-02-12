# The Rick and Morty API (via a Zuplo Gateway)

A sample [Zuplo](https://zuplo.com) API gateway that proxies the [Rick and Morty API](https://rickandmortyapi.com), demonstrating API key authentication, request proxying, URL rewriting, and the [Zudoku](https://zudoku.dev) developer portal.

## Project Structure

```
rick-and-morty/
├── config/
│   ├── routes.oas.json     # API routes (OpenAPI 3.1 + Zuplo extensions)
│   ├── legacy.oas.json     # Dev portal redirect routes
│   └── policies.json       # Inbound/outbound policies
├── modules/
│   ├── zuplo.runtime.ts    # Runtime plugins (logging)
│   └── mock.ts             # Custom inbound policy
├── schemas/                # JSON response schemas
├── docs/                   # Zudoku developer portal
│   ├── zudoku.config.tsx   # Portal configuration
│   ├── pages/              # Markdown documentation
│   └── package.json
├── zuplo.jsonc             # Zuplo project manifest
└── package.json            # Root package (workspaces)
```

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [Zuplo CLI](https://zuplo.com/docs/cli) (`npm install -g zuplo`)

### Install Dependencies

```bash
npm install
```

### Run Locally

Start the API gateway:

```bash
npm run dev
```

Start the developer portal:

```bash
npm run docs
```

### Deploy

```bash
npx zuplo deploy
```

## API Endpoints

All API routes require an API key (via the `api-key-inbound` policy).

| Endpoint | Description |
|----------|-------------|
| `GET /v1/characters` | List all characters (supports filtering and pagination) |
| `GET /v1/characters/:characterId` | Get character(s) by ID |
| `GET /v1/locations` | List all locations |
| `GET /v1/locations/:locationId` | Get location(s) by ID |
| `GET /v1/episodes` | List all episodes |
| `GET /v1/episodes/:episodeId` | Get episode(s) by ID |
| `GET /openapi.json` | OpenAPI specification |

## Developer Portal

The developer portal is powered by [Zudoku](https://zudoku.dev) and runs on its own dedicated domain. It provides interactive API documentation, authentication via Auth0, and API key management.

Configuration lives in `docs/zudoku.config.tsx`. Documentation pages are Markdown files in `docs/pages/`.

## How It Works

1. **Request proxying** — Routes use `urlRewriteHandler` to forward requests to the upstream Rick and Morty API at `rickandmortyapi.com`.
2. **API key auth** — The `api-key-inbound` policy validates API keys on all `/v1/*` endpoints.
3. **URL rewriting** — The `replace-urls` outbound policy rewrites upstream URLs in API responses to point to this gateway instead.
4. **Dev portal redirects** — The root `/` route redirects to `/docs` via `redirectHandler`, and the `legacyDevPortalHandler` then redirects `/docs/*` to the Zudoku portal's dedicated domain.

## Credits

Full credit to the original [Rick and Morty API](https://rickandmortyapi.com) by [Axel Fuhrmann](https://github.com/afuh/rick-and-morty-api).

![Rick](https://rickandmortyapi.com/api/character/avatar/631.jpeg)
