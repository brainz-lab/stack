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

  # Generate keys
  echo "🔑 Generating keys..."
  RECALL_MASTER=$(openssl rand -hex 32)
  REFLEX_MASTER=$(openssl rand -hex 32)
  PULSE_MASTER=$(openssl rand -hex 32)
  RECALL_SECRET=$(openssl rand -hex 64)
  REFLEX_SECRET=$(openssl rand -hex 64)
  PULSE_SECRET=$(openssl rand -hex 64)
  RECALL_INGEST="rcl_$(openssl rand -hex 16)"
  REFLEX_INGEST="rfx_$(openssl rand -hex 16)"
  PULSE_INGEST="pls_$(openssl rand -hex 16)"
  BRAINZLAB_SECRET=$(openssl rand -hex 64)

  # Update .env with generated keys
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^RECALL_MASTER_KEY=.*/RECALL_MASTER_KEY=$RECALL_MASTER/" .env
    sed -i '' "s/^REFLEX_MASTER_KEY=.*/REFLEX_MASTER_KEY=$REFLEX_MASTER/" .env
    sed -i '' "s/^PULSE_MASTER_KEY=.*/PULSE_MASTER_KEY=$PULSE_MASTER/" .env
    sed -i '' "s/^RECALL_SECRET_KEY=.*/RECALL_SECRET_KEY=$RECALL_SECRET/" .env
    sed -i '' "s/^REFLEX_SECRET_KEY=.*/REFLEX_SECRET_KEY=$REFLEX_SECRET/" .env
    sed -i '' "s/^PULSE_SECRET_KEY=.*/PULSE_SECRET_KEY=$PULSE_SECRET/" .env
    sed -i '' "s/^RECALL_INGEST_KEY=.*/RECALL_INGEST_KEY=$RECALL_INGEST/" .env
    sed -i '' "s/^REFLEX_INGEST_KEY=.*/REFLEX_INGEST_KEY=$REFLEX_INGEST/" .env
    sed -i '' "s/^PULSE_INGEST_KEY=.*/PULSE_INGEST_KEY=$PULSE_INGEST/" .env
    sed -i '' "s/^BRAINZLAB_SECRET_KEY=.*/BRAINZLAB_SECRET_KEY=$BRAINZLAB_SECRET/" .env
  else
    sed -i "s/^RECALL_MASTER_KEY=.*/RECALL_MASTER_KEY=$RECALL_MASTER/" .env
    sed -i "s/^REFLEX_MASTER_KEY=.*/REFLEX_MASTER_KEY=$REFLEX_MASTER/" .env
    sed -i "s/^PULSE_MASTER_KEY=.*/PULSE_MASTER_KEY=$PULSE_MASTER/" .env
    sed -i "s/^RECALL_SECRET_KEY=.*/RECALL_SECRET_KEY=$RECALL_SECRET/" .env
    sed -i "s/^REFLEX_SECRET_KEY=.*/REFLEX_SECRET_KEY=$REFLEX_SECRET/" .env
    sed -i "s/^PULSE_SECRET_KEY=.*/PULSE_SECRET_KEY=$PULSE_SECRET/" .env
    sed -i "s/^RECALL_INGEST_KEY=.*/RECALL_INGEST_KEY=$RECALL_INGEST/" .env
    sed -i "s/^REFLEX_INGEST_KEY=.*/REFLEX_INGEST_KEY=$REFLEX_INGEST/" .env
    sed -i "s/^PULSE_INGEST_KEY=.*/PULSE_INGEST_KEY=$PULSE_INGEST/" .env
    sed -i "s/^BRAINZLAB_SECRET_KEY=.*/BRAINZLAB_SECRET_KEY=$BRAINZLAB_SECRET/" .env
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
echo "   This adds RECALL_URL, REFLEX_URL, PULSE_URL, and BRAINZLAB_SECRET_KEY"
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
    sed -i '' '/^export BRAINZLAB_SECRET_KEY=/d' "$SHELL_PROFILE" 2>/dev/null || true
  else
    sed -i '/^# Brainz Lab Configuration/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export RECALL_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export REFLEX_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export PULSE_URL=/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/^export BRAINZLAB_SECRET_KEY=/d' "$SHELL_PROFILE" 2>/dev/null || true
  fi

  # Add new entries
  cat >> "$SHELL_PROFILE" << EOF

# Brainz Lab Configuration
export RECALL_URL="${RECALL_URL}"
export REFLEX_URL="${REFLEX_URL}"
export PULSE_URL="${PULSE_URL}"
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
