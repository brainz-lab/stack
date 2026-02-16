#!/bin/bash
set -e

echo "🧠 Setting up Brainz Lab Stack..."

# Check requirements
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required. Install from https://docker.com"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v "docker compose" >/dev/null 2>&1 || { echo "❌ Docker Compose is required"; exit 1; }

# Create .env if not exists
if [ ! -f .env ]; then
  echo "📝 Creating .env file..."
  cp .env.example .env

  # Generate keys for all services
  echo "🔑 Generating keys..."
  RECALL_SECRET=$(openssl rand -hex 64)
  REFLEX_SECRET=$(openssl rand -hex 64)
  PULSE_SECRET=$(openssl rand -hex 64)
  FLUX_SECRET=$(openssl rand -hex 64)
  SIGNAL_SECRET=$(openssl rand -hex 64)
  VAULT_SECRET=$(openssl rand -hex 64)
  BEACON_SECRET=$(openssl rand -hex 64)
  VISION_SECRET=$(openssl rand -hex 64)
  SENTINEL_SECRET=$(openssl rand -hex 64)
  RECALL_INGEST="rcl_$(openssl rand -hex 16)"
  REFLEX_INGEST="rfx_$(openssl rand -hex 16)"
  PULSE_INGEST="pls_$(openssl rand -hex 16)"
  FLUX_INGEST="flx_$(openssl rand -hex 16)"
  SIGNAL_INGEST="sig_$(openssl rand -hex 16)"
  VAULT_INGEST="vlt_$(openssl rand -hex 16)"
  BEACON_INGEST="bcn_$(openssl rand -hex 16)"
  VISION_INGEST="vis_$(openssl rand -hex 16)"
  SENTINEL_INGEST="snt_$(openssl rand -hex 16)"
  BRAINZLAB_SECRET=$(openssl rand -hex 64)
  VAULT_API=$(openssl rand -hex 32)

  # Update .env with generated keys
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^RECALL_SECRET_KEY=.*/RECALL_SECRET_KEY=$RECALL_SECRET/" .env
    sed -i '' "s/^REFLEX_SECRET_KEY=.*/REFLEX_SECRET_KEY=$REFLEX_SECRET/" .env
    sed -i '' "s/^PULSE_SECRET_KEY=.*/PULSE_SECRET_KEY=$PULSE_SECRET/" .env
    sed -i '' "s/^FLUX_SECRET_KEY=.*/FLUX_SECRET_KEY=$FLUX_SECRET/" .env
    sed -i '' "s/^SIGNAL_SECRET_KEY=.*/SIGNAL_SECRET_KEY=$SIGNAL_SECRET/" .env
    sed -i '' "s/^VAULT_SECRET_KEY=.*/VAULT_SECRET_KEY=$VAULT_SECRET/" .env
    sed -i '' "s/^BEACON_SECRET_KEY=.*/BEACON_SECRET_KEY=$BEACON_SECRET/" .env
    sed -i '' "s/^VISION_SECRET_KEY=.*/VISION_SECRET_KEY=$VISION_SECRET/" .env
    sed -i '' "s/^SENTINEL_SECRET_KEY=.*/SENTINEL_SECRET_KEY=$SENTINEL_SECRET/" .env
    sed -i '' "s/^RECALL_INGEST_KEY=.*/RECALL_INGEST_KEY=$RECALL_INGEST/" .env
    sed -i '' "s/^REFLEX_INGEST_KEY=.*/REFLEX_INGEST_KEY=$REFLEX_INGEST/" .env
    sed -i '' "s/^PULSE_INGEST_KEY=.*/PULSE_INGEST_KEY=$PULSE_INGEST/" .env
    sed -i '' "s/^FLUX_INGEST_KEY=.*/FLUX_INGEST_KEY=$FLUX_INGEST/" .env
    sed -i '' "s/^SIGNAL_INGEST_KEY=.*/SIGNAL_INGEST_KEY=$SIGNAL_INGEST/" .env
    sed -i '' "s/^VAULT_INGEST_KEY=.*/VAULT_INGEST_KEY=$VAULT_INGEST/" .env
    sed -i '' "s/^BEACON_INGEST_KEY=.*/BEACON_INGEST_KEY=$BEACON_INGEST/" .env
    sed -i '' "s/^VISION_INGEST_KEY=.*/VISION_INGEST_KEY=$VISION_INGEST/" .env
    sed -i '' "s/^SENTINEL_INGEST_KEY=.*/SENTINEL_INGEST_KEY=$SENTINEL_INGEST/" .env
    sed -i '' "s/^BRAINZLAB_SECRET_KEY=.*/BRAINZLAB_SECRET_KEY=$BRAINZLAB_SECRET/" .env
    sed -i '' "s/^VAULT_API_KEY=.*/VAULT_API_KEY=$VAULT_API/" .env
  else
    sed -i "s/^RECALL_SECRET_KEY=.*/RECALL_SECRET_KEY=$RECALL_SECRET/" .env
    sed -i "s/^REFLEX_SECRET_KEY=.*/REFLEX_SECRET_KEY=$REFLEX_SECRET/" .env
    sed -i "s/^PULSE_SECRET_KEY=.*/PULSE_SECRET_KEY=$PULSE_SECRET/" .env
    sed -i "s/^FLUX_SECRET_KEY=.*/FLUX_SECRET_KEY=$FLUX_SECRET/" .env
    sed -i "s/^SIGNAL_SECRET_KEY=.*/SIGNAL_SECRET_KEY=$SIGNAL_SECRET/" .env
    sed -i "s/^VAULT_SECRET_KEY=.*/VAULT_SECRET_KEY=$VAULT_SECRET/" .env
    sed -i "s/^BEACON_SECRET_KEY=.*/BEACON_SECRET_KEY=$BEACON_SECRET/" .env
    sed -i "s/^VISION_SECRET_KEY=.*/VISION_SECRET_KEY=$VISION_SECRET/" .env
    sed -i "s/^SENTINEL_SECRET_KEY=.*/SENTINEL_SECRET_KEY=$SENTINEL_SECRET/" .env
    sed -i "s/^RECALL_INGEST_KEY=.*/RECALL_INGEST_KEY=$RECALL_INGEST/" .env
    sed -i "s/^REFLEX_INGEST_KEY=.*/REFLEX_INGEST_KEY=$REFLEX_INGEST/" .env
    sed -i "s/^PULSE_INGEST_KEY=.*/PULSE_INGEST_KEY=$PULSE_INGEST/" .env
    sed -i "s/^FLUX_INGEST_KEY=.*/FLUX_INGEST_KEY=$FLUX_INGEST/" .env
    sed -i "s/^SIGNAL_INGEST_KEY=.*/SIGNAL_INGEST_KEY=$SIGNAL_INGEST/" .env
    sed -i "s/^VAULT_INGEST_KEY=.*/VAULT_INGEST_KEY=$VAULT_INGEST/" .env
    sed -i "s/^BEACON_INGEST_KEY=.*/BEACON_INGEST_KEY=$BEACON_INGEST/" .env
    sed -i "s/^VISION_INGEST_KEY=.*/VISION_INGEST_KEY=$VISION_INGEST/" .env
    sed -i "s/^SENTINEL_INGEST_KEY=.*/SENTINEL_INGEST_KEY=$SENTINEL_INGEST/" .env
    sed -i "s/^BRAINZLAB_SECRET_KEY=.*/BRAINZLAB_SECRET_KEY=$BRAINZLAB_SECRET/" .env
    sed -i "s/^VAULT_API_KEY=.*/VAULT_API_KEY=$VAULT_API/" .env
  fi

  echo "✅ Generated secure keys"
else
  echo "📝 Using existing .env file"
fi

# Load current env values
set -a
source .env
set +a

# Ask about global export
echo ""
echo "🌐 Would you like to export Brainz Lab configuration to your shell profile?"
echo "   This adds all service URLs and BRAINZLAB_SECRET_KEY"
echo "   to your shell so they're available in all terminal sessions."
echo ""
read -p "   Export to shell profile? [y/N] " export_choice

if [[ "$export_choice" =~ ^[Yy]$ ]]; then
  # Detect shell profile
  if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
  elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
  else
    SHELL_PROFILE="$HOME/.profile"
  fi

  echo ""
  echo "   Adding to $SHELL_PROFILE..."

  # Remove old entries if they exist
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/^# Brainz Lab Configuration/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export RECALL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export REFLEX_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export PULSE_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export FLUX_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export SIGNAL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export VAULT_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export BEACON_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export VISION_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export SENTINEL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '' '/^export BRAINZLAB_SECRET_KEY=/d' "$SHELL_PROFILE" 2>/dev/null || true
  else
    sed -i '/^# Brainz Lab Configuration/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export RECALL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export REFLEX_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export PULSE_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export FLUX_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export SIGNAL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export VAULT_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export BEACON_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export VISION_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export SENTINEL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export BRAINZLAB_SECRET_KEY=/d' "$SHELL_PROFILE" 2>/dev/null || true
  fi

  # Add new entries
  cat >> "$SHELL_PROFILE" << EOF

# Brainz Lab Configuration
export RECALL_URL="${RECALL_URL}"
export REFLEX_URL="${REFLEX_URL}"
export PULSE_URL="${PULSE_URL}"
export FLUX_URL="${FLUX_URL}"
export SIGNAL_URL="${SIGNAL_URL}"
export VAULT_URL="${VAULT_URL}"
export BEACON_URL="${BEACON_URL}"
export VISION_URL="${VISION_URL}"
export SENTINEL_URL="${SENTINEL_URL}"
export BRAINZLAB_SECRET_KEY="${BRAINZLAB_SECRET_KEY}"
EOF

  echo "   ✅ Configuration exported to $SHELL_PROFILE"
  echo "   💡 Run 'source $SHELL_PROFILE' or open a new terminal to apply."
fi

# Pull latest images
echo ""
echo "📦 Pulling latest images..."
docker-compose pull

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review and customize .env if needed"
echo "  2. Start the stack: ./scripts/start.sh"
echo ""
