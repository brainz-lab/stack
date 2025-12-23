#!/bin/bash
set -e

echo "🚀 Starting Brainz Lab Stack..."

# Check if .env exists
if [ ! -f .env ]; then
  echo "❌ .env file not found. Run ./scripts/setup.sh first"
  exit 1
fi

# Load environment variables
set -a
source .env
set +a

# Extract hosts from URLs (remove protocol and port)
extract_host() {
  echo "$1" | sed -E 's|^https?://||' | sed -E 's|:[0-9]+$||' | sed -E 's|/.*$||'
}

RECALL_HOST=$(extract_host "${RECALL_URL:-http://recall.localhost}")
REFLEX_HOST=$(extract_host "${REFLEX_URL:-http://reflex.localhost}")
PULSE_HOST=$(extract_host "${PULSE_URL:-http://pulse.localhost}")

# Export for Traefik
export RECALL_HOST REFLEX_HOST PULSE_HOST

# Start services
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check health via Traefik
echo ""
echo "🔍 Checking service health..."

check_service() {
  local name=$1
  local url=$2
  local max_attempts=30
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if curl -s -o /dev/null -w "%{http_code}" "${url}/up" 2>/dev/null | grep -q "200"; then
      echo "  ✅ $name is ready"
      return 0
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "  ⚠️  $name may still be starting (check logs)"
  return 0
}

check_service "Recall" "${RECALL_URL:-http://recall.localhost}"
check_service "Reflex" "${REFLEX_URL:-http://reflex.localhost}"
check_service "Pulse" "${PULSE_URL:-http://pulse.localhost}"

echo ""
echo "✅ Brainz Lab Stack is running!"
echo ""
echo "📍 Services (via Traefik):"
echo "   Recall:   ${RECALL_URL:-http://recall.localhost}"
echo "   Reflex:   ${REFLEX_URL:-http://reflex.localhost}"
echo "   Pulse:    ${PULSE_URL:-http://pulse.localhost}"
echo ""
echo "📊 View logs: ./scripts/logs.sh [service]"
echo "🛑 Stop:      ./scripts/stop.sh"
echo ""
