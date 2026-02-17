# Brainz Lab Stack

Self-hosted observability and developer tools platform for Rails applications.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-brainzlab.ai-orange)](https://docs.brainzlab.ai/self-hosting/overview)

## Overview

Brainz Lab provides complete observability and developer tools for your Rails apps:

**Observability**
- **Recall** - Structured logging with powerful search
- **Reflex** - Error tracking with smart grouping
- **Pulse** - APM with distributed tracing
- **Beacon** - Uptime monitoring and status pages
- **Sentinel** - Infrastructure and host monitoring

**Developer Tools**
- **Signal** - Alerting and notifications hub
- **Flux** - Feature flags and experiments
- **Vault** - Secrets management
- **Vision** - Visual regression testing

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/brainz-lab/stack/main/install.sh | bash
```

## Requirements

- Docker & Docker Compose
- 4GB RAM minimum (8GB recommended for full stack)

> **Note:** The first start takes ~2 minutes while 36 databases are created and schemas are loaded. Subsequent starts are much faster.

## Services

### Application Services

| Service | Port | Subdomain | Description |
|---------|------|-----------|-------------|
| Recall | 3001 | recall.localhost | Structured logging |
| Reflex | 3002 | reflex.localhost | Error tracking |
| Pulse | 3003 | pulse.localhost | APM & tracing |
| Flux | 3004 | flux.localhost | Feature flags |
| Signal | 3005 | signal.localhost | Alerting hub |
| Vault | 3006 | vault.localhost | Secrets management |
| Beacon | 3007 | beacon.localhost | Uptime monitoring |
| Vision | 3008 | vision.localhost | Visual testing |
| Sentinel | 3009 | sentinel.localhost | Infrastructure monitoring |

### Infrastructure Services

| Service | Port | Description |
|---------|------|-------------|
| Traefik | 80, 8080 | Reverse proxy (dashboard on 8080) |
| TimescaleDB | 5432 | PostgreSQL with time-series extensions |
| Redis | 6379 | Cache and job queues |
| MinIO | 9000, 9001 | S3-compatible object storage |

## Usage

### Start

```bash
./scripts/start.sh
```

### Stop

```bash
./scripts/stop.sh
```

### View Logs

```bash
./scripts/logs.sh          # All services
./scripts/logs.sh recall   # Single service
```

### Reset Data

```bash
./scripts/reset.sh
```

## Accessing Services

### Via Subdomains (Recommended)

Traefik routes requests based on subdomain. On macOS, `.localhost` domains resolve automatically. On Linux, add to `/etc/hosts`:

```
127.0.0.1 recall.localhost reflex.localhost pulse.localhost
127.0.0.1 flux.localhost signal.localhost vault.localhost
127.0.0.1 beacon.localhost vision.localhost sentinel.localhost
```

Then access: `http://recall.localhost`, `http://reflex.localhost`, etc.

### Via Direct Ports

Access services directly: `http://localhost:3001` (Recall), `http://localhost:3002` (Reflex), etc.

### Traefik Dashboard

View routing and health: `http://localhost:8080`

## Integrate with Your App

### 1. Add the SDK

```ruby
# Gemfile
gem 'brainzlab'
```

### 2. Configure

```ruby
# config/initializers/brainzlab.rb
BrainzLab.configure do |config|
  config.secret_key = ENV['BRAINZLAB_SECRET_KEY']

  # Self-hosted URLs (via Traefik subdomains)
  config.recall_url = ENV['RECALL_URL']   # http://recall.localhost
  config.reflex_url = ENV['REFLEX_URL']   # http://reflex.localhost
  config.pulse_url  = ENV['PULSE_URL']    # http://pulse.localhost
  config.signal_url = ENV['SIGNAL_URL']   # http://signal.localhost
  config.flux_url   = ENV['FLUX_URL']     # http://flux.localhost
  config.vault_url  = ENV['VAULT_URL']    # http://vault.localhost
end
```

> **Tip:** Run `./scripts/setup.sh` to generate keys and optionally export URLs to your shell profile.

### 3. Use

```ruby
# Logging
BrainzLab::Recall.info("User signed up", user_id: user.id)

# Error tracking (automatic in Rails, or manual)
BrainzLab::Reflex.capture(exception, user: current_user)

# APM (automatic instrumentation)
# Just install the gem and it works!

# Custom metrics
BrainzLab::Pulse.increment("orders.created")
BrainzLab::Pulse.gauge("queue.size", Sidekiq::Queue.new.size)

# Feature flags
if BrainzLab::Flux.enabled?(:new_checkout, user: current_user)
  # New checkout flow
end

# Secrets
api_key = BrainzLab::Vault.get("stripe/api_key")

# Alerts
BrainzLab::Signal.trigger("high_error_rate", severity: :critical)
```

## Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

### Key Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_USER` | Database user | `brainzlab` |
| `POSTGRES_PASSWORD` | Database password | `brainzlab` |
| `RECALL_PORT` | Recall port | `3001` |
| `REFLEX_PORT` | Reflex port | `3002` |
| `PULSE_PORT` | Pulse port | `3003` |
| `FLUX_PORT` | Flux port | `3004` |
| `SIGNAL_PORT` | Signal port | `3005` |
| `VAULT_PORT` | Vault port | `3006` |
| `BEACON_PORT` | Beacon port | `3007` |
| `VISION_PORT` | Vision port | `3008` |
| `SENTINEL_PORT` | Sentinel port | `3009` |

### Subdomain Configuration (Production)

| Variable | Description | Default |
|----------|-------------|---------|
| `RECALL_HOST` | Recall subdomain | `recall.localhost` |
| `REFLEX_HOST` | Reflex subdomain | `reflex.localhost` |
| `PULSE_HOST` | Pulse subdomain | `pulse.localhost` |
| `FLUX_HOST` | Flux subdomain | `flux.localhost` |
| `SIGNAL_HOST` | Signal subdomain | `signal.localhost` |
| `VAULT_HOST` | Vault subdomain | `vault.localhost` |
| `BEACON_HOST` | Beacon subdomain | `beacon.localhost` |
| `VISION_HOST` | Vision subdomain | `vision.localhost` |
| `SENTINEL_HOST` | Sentinel subdomain | `sentinel.localhost` |

### Using GitHub Container Registry

To use GHCR instead of Docker Hub:

```env
RECALL_IMAGE=ghcr.io/brainz-lab/recall:latest
REFLEX_IMAGE=ghcr.io/brainz-lab/reflex:latest
PULSE_IMAGE=ghcr.io/brainz-lab/pulse:latest
# ... etc for other services
```

## Production Deployment

### Prerequisites

1. **Use a managed database** (RDS, Cloud SQL, etc.) or secure your TimescaleDB
2. **Set up HTTPS** - Traefik can handle Let's Encrypt automatically
3. **Configure proper secrets** in `.env`
4. **Set up backups** for PostgreSQL and MinIO

### DNS Configuration

Set up DNS records pointing to your server:

```
recall.yourdomain.com    → Your server IP
reflex.yourdomain.com    → Your server IP
pulse.yourdomain.com     → Your server IP
flux.yourdomain.com      → Your server IP
signal.yourdomain.com    → Your server IP
vault.yourdomain.com     → Your server IP
beacon.yourdomain.com    → Your server IP
vision.yourdomain.com    → Your server IP
sentinel.yourdomain.com  → Your server IP
```

### Environment Variables for Production

```env
# Database
POSTGRES_USER=brainzlab
POSTGRES_PASSWORD=<strong-password>

# Master keys - leave EMPTY for pre-built images.
# The images include encrypted credentials that match their built-in keys.
# Setting custom master keys will cause "key must be 16 bytes" errors.
RECALL_MASTER_KEY=
REFLEX_MASTER_KEY=
PULSE_MASTER_KEY=
FLUX_MASTER_KEY=
SIGNAL_MASTER_KEY=
VAULT_MASTER_KEY=
BEACON_MASTER_KEY=
VISION_MASTER_KEY=
SENTINEL_MASTER_KEY=

# Secret keys and SDK key (auto-generated by setup.sh)
BRAINZLAB_SECRET_KEY=<generated-key>

# Subdomains (your domain)
RECALL_HOST=recall.yourdomain.com
REFLEX_HOST=reflex.yourdomain.com
PULSE_HOST=pulse.yourdomain.com
FLUX_HOST=flux.yourdomain.com
SIGNAL_HOST=signal.yourdomain.com
VAULT_HOST=vault.yourdomain.com
BEACON_HOST=beacon.yourdomain.com
VISION_HOST=vision.yourdomain.com
SENTINEL_HOST=sentinel.yourdomain.com
```

### Traefik with HTTPS

Update `traefik/traefik.yml` for production with Let's Encrypt:

```yaml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Your Rails App                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    brainzlab gem                         │    │
│  │  Recall │ Reflex │ Pulse │ Signal │ Flux │ Vault        │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Traefik                                  │
│              (Reverse Proxy + Load Balancer)                     │
│         recall.* │ reflex.* │ pulse.* │ ...                     │
└─────────────────────────────────────────────────────────────────┘
                              │
     ┌────────────────────────┼────────────────────────┐
     ▼                        ▼                        ▼
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ Recall  │  │ Reflex  │  │  Pulse  │  │  Flux   │  │ Signal  │
│  :3001  │  │  :3002  │  │  :3003  │  │  :3004  │  │  :3005  │
└────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘
     │            │            │            │            │
     └────────────┴────────────┴────────────┴────────────┘
                              │
     ┌────────────────────────┼────────────────────────┐
     ▼                        ▼                        ▼
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  Vault  │  │ Beacon  │  │ Vision  │  │Sentinel │  │  MinIO  │
│  :3006  │  │  :3007  │  │  :3008  │  │  :3009  │  │  :9000  │
└────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └─────────┘
     │            │            │            │
     └────────────┴────────────┴────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
       ┌─────────────┐                 ┌─────────────┐
       │ TimescaleDB │                 │    Redis    │
       │    :5432    │                 │    :6379    │
       └─────────────┘                 └─────────────┘
```

## Health Checks

All services expose a `/up` endpoint for health checks:

```bash
curl http://localhost:3001/up  # Recall
curl http://localhost:3002/up  # Reflex
# ... etc
```

Traefik dashboard shows service health: `http://localhost:8080`

## Troubleshooting

### Services won't start

Check if ports are in use:
```bash
lsof -i :3001  # Check if port is taken
```

### Container name conflicts

If you see "container name already in use" errors:
```bash
docker-compose down --remove-orphans
docker-compose up -d
```

### Database connection errors

Ensure TimescaleDB is healthy:
```bash
docker-compose ps timescaledb
docker-compose logs timescaledb
```

### Services return 502

On first boot, services need ~2 minutes for database setup. Wait and retry:
```bash
# Check a specific service
docker-compose logs vault
# Look for "Listening on http://0.0.0.0:3000" to confirm it's ready
```

### Seed warnings

Some services may show seed warnings like `NoMethodError` or `RecordInvalid` during first boot. These are non-fatal - the services still start and function correctly.

### Reset everything

If something goes wrong and you want a completely fresh start:
```bash
./scripts/reset.sh          # Removes all data and volumes
./scripts/start.sh          # Start fresh
```

### Traefik routing issues

Check Traefik dashboard at `http://localhost:8080` for:
- Service health (green = healthy)
- Router configuration
- Active routes

### View all logs

```bash
docker-compose logs -f
```

## Documentation

Full documentation: [docs.brainzlab.ai/self-hosting](https://docs.brainzlab.ai/self-hosting/overview)

## Related

- [brainzlab-ruby](https://github.com/brainz-lab/brainzlab-ruby) - Ruby SDK
- [Recall](https://github.com/brainz-lab/recall) - Logging service
- [Reflex](https://github.com/brainz-lab/reflex) - Error tracking service
- [Pulse](https://github.com/brainz-lab/pulse) - APM service
- [Flux](https://github.com/brainz-lab/flux) - Feature flags service
- [Signal](https://github.com/brainz-lab/signal) - Alerting service
- [Vault](https://github.com/brainz-lab/vault) - Secrets service
- [Beacon](https://github.com/brainz-lab/beacon) - Uptime monitoring service
- [Vision](https://github.com/brainz-lab/vision) - Visual testing service
- [Sentinel](https://github.com/brainz-lab/sentinel) - Infrastructure monitoring service

## License

MIT
