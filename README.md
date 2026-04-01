# openclaw

Runs [openclaw](https://github.com/openclaw/openclaw) behind [open-claw-secure-proxy](https://github.com/mathieu/open-claw-secure-proxy) to intercept and rewrite outgoing HTTP/HTTPS headers (e.g. inject credentials from 1Password).

## Architecture

```
openclaw container
  HTTP_PROXY / HTTPS_PROXY
        |
        v
open-claw-secure-proxy :8080   (MITM, rewrites headers, signs TLS with its CA)
        |
        v
     Internet
```

The proxy generates TLS certificates on the fly, signed by a local CA. openclaw trusts that CA via `NODE_EXTRA_CA_CERTS` (local dev) or by baking the cert into the image (CI/published image).

## Prerequisites

- Docker + Compose
- `openssl`
- [`open-claw-secure-proxy`](https://github.com/mathieu/open-claw-secure-proxy) cloned at `../open-claw-secure-proxy` (sibling directory)

## First-time setup

**1. Generate the CA certificate**

```bash
./scripts/generate-ca.sh
```

This creates `proxy-ca.crt` (safe to commit) and `proxy-ca.key` (already in `.gitignore`).
The script prints the `CA_CERT` and `CA_KEY` base64 values needed for the next step.

**2. Configure environment**

```bash
cp .env.example .env
# Fill in CA_CERT and CA_KEY from the script output above
```

**3. Run**

```bash
docker compose up
```

openclaw is available at `http://localhost:18789`.

## Published image (CI)

The GitHub Actions workflow builds a hardened image with the CA baked in:

```
ghcr.io/<your-org>/openclaw:latest
ghcr.io/<your-org>/openclaw:v2026.3.23
```

To use it in production, replace the `build:` key in `docker-compose.yml` with `image:`.

### Required GitHub secrets

| Secret | Value |
|---|---|
| `PROXY_CA_CERT_B64` | `base64 -w0 proxy-ca.crt` |

The script prints the exact `gh secret set` commands after generating the CA.

## Automatic upstream tracking

`check-upstream.yml` runs daily and compares the latest [openclaw release](https://github.com/openclaw/openclaw/releases) with `OPENCLAW_VERSION`. When a new version is detected it commits the bump, which triggers `build.yml` automatically.

You can also trigger a manual build from the Actions tab with an explicit version override.

