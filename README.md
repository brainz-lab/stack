# Brainz Lab Stack

Self-hosted observability platform for Rails applications.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

Brainz Lab provides complete observability for your Rails apps:

- **Recall** - Structured logging with powerful search
- **Reflex** - Error tracking with smart grouping
- **Pulse** - APM with distributed tracing

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/brainz-lab/stack/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/brainz-lab/stack.git
cd stack
./scripts/setup.sh
./scripts/start.sh
```

## Requirements

- Docker & Docker Compose
- 2GB RAM minimum (4GB recommended)

## Services

| Service | Port | Description |
|---------|------|-------------|
| Recall | 3001 | Structured logging |
| Reflex | 3002 | Error tracking |
| Pulse | 3003 | APM & tracing |

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

  # Self-hosted URLs
  config.recall_url = 'http://localhost:3001'
  config.reflex_url = 'http://localhost:3002'
  config.pulse_url = 'http://localhost:3003'
end
```

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
```

## Configuration

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

### Key Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_PASSWORD` | Database password | `brainzlab` |
| `RECALL_PORT` | Recall port | `3001` |
| `REFLEX_PORT` | Reflex port | `3002` |
| `PULSE_PORT` | Pulse port | `3003` |

### Using GitHub Container Registry

To use GHCR instead of Docker Hub:

```env
RECALL_IMAGE=ghcr.io/brainz-lab/recall:latest
REFLEX_IMAGE=ghcr.io/brainz-lab/reflex:latest
PULSE_IMAGE=ghcr.io/brainz-lab/pulse:latest
```

## Production Deployment

For production, we recommend:

1. **Use a managed database** (RDS, Cloud SQL, etc.)
2. **Set up HTTPS** with a reverse proxy (nginx, Traefik, Caddy)
3. **Configure proper secrets** in `.env`
4. **Set up backups** for PostgreSQL

### Environment Variables for Production

```env
# Required
POSTGRES_PASSWORD=<strong-password>
RECALL_MASTER_KEY=<generated-key>
REFLEX_MASTER_KEY=<generated-key>
PULSE_MASTER_KEY=<generated-key>
SERVICE_KEY=<generated-key>

# URLs (your domain)
RECALL_URL=https://recall.yourdomain.com
REFLEX_URL=https://reflex.yourdomain.com
PULSE_URL=https://pulse.yourdomain.com
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Your Rails App                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    brainzlab gem                         │    │
│  │  Recall (logs) │ Reflex (errors) │ Pulse (traces)       │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Brainz Lab Stack                            │
│                                                                  │
│       ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│       │  Recall  │    │  Reflex  │    │  Pulse   │             │
│       │  :3001   │    │  :3002   │    │  :3003   │             │
│       └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│            │               │               │                    │
│       ┌────┴───────────────┴───────────────┴────┐              │
│       │          PostgreSQL + Redis              │              │
│       └──────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Documentation

- [SDK Documentation](https://github.com/brainz-lab/brainzlab-ruby)
- [Recall - Logging](https://github.com/brainz-lab/recall)
- [Reflex - Errors](https://github.com/brainz-lab/reflex)
- [Pulse - APM](https://github.com/brainz-lab/pulse)

## License

MIT
