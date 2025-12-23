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

  # Generate master keys
  echo "🔑 Generating master keys..."
  PLATFORM_KEY=$(openssl rand -hex 32)
  RECALL_KEY=$(openssl rand -hex 32)
  REFLEX_KEY=$(openssl rand -hex 32)
  PULSE_KEY=$(openssl rand -hex 32)
  SERVICE_KEY=$(openssl rand -hex 32)

  # Update .env with generated keys
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^PLATFORM_MASTER_KEY=.*/PLATFORM_MASTER_KEY=$PLATFORM_KEY/" .env
    sed -i '' "s/^RECALL_MASTER_KEY=.*/RECALL_MASTER_KEY=$RECALL_KEY/" .env
    sed -i '' "s/^REFLEX_MASTER_KEY=.*/REFLEX_MASTER_KEY=$REFLEX_KEY/" .env
    sed -i '' "s/^PULSE_MASTER_KEY=.*/PULSE_MASTER_KEY=$PULSE_KEY/" .env
    sed -i '' "s/^SERVICE_KEY=.*/SERVICE_KEY=$SERVICE_KEY/" .env
  else
    sed -i "s/^PLATFORM_MASTER_KEY=.*/PLATFORM_MASTER_KEY=$PLATFORM_KEY/" .env
    sed -i "s/^RECALL_MASTER_KEY=.*/RECALL_MASTER_KEY=$RECALL_KEY/" .env
    sed -i "s/^REFLEX_MASTER_KEY=.*/REFLEX_MASTER_KEY=$REFLEX_KEY/" .env
    sed -i "s/^PULSE_MASTER_KEY=.*/PULSE_MASTER_KEY=$PULSE_KEY/" .env
    sed -i "s/^SERVICE_KEY=.*/SERVICE_KEY=$SERVICE_KEY/" .env
  fi

  echo "✅ Generated secure keys"
else
  echo "📝 Using existing .env file"
fi

# Pull latest images
echo "📦 Pulling latest images..."
docker-compose pull

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review and customize .env if needed"
echo "  2. Start the stack: ./scripts/start.sh"
echo ""
