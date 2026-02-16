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
FLUX_HOST=$(extract_host "${FLUX_URL:-http://flux.localhost}")
SIGNAL_HOST=$(extract_host "${SIGNAL_URL:-http://signal.localhost}")
VAULT_HOST=$(extract_host "${VAULT_URL:-http://vault.localhost}")
BEACON_HOST=$(extract_host "${BEACON_URL:-http://beacon.localhost}")
VISION_HOST=$(extract_host "${VISION_URL:-http://vision.localhost}")
SENTINEL_HOST=$(extract_host "${SENTINEL_URL:-http://sentinel.localhost}")

# Export for Traefik
export RECALL_HOST REFLEX_HOST PULSE_HOST FLUX_HOST SIGNAL_HOST VAULT_HOST BEACON_HOST VISION_HOST SENTINEL_HOST

# Clean up any stale containers from previous runs
docker-compose down --remove-orphans 2>/dev/null || true

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
  local max_attempts=60
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

check_service "Vault" "${VAULT_URL:-http://vault.localhost}"
check_service "Recall" "${RECALL_URL:-http://recall.localhost}"
check_service "Reflex" "${REFLEX_URL:-http://reflex.localhost}"
check_service "Pulse" "${PULSE_URL:-http://pulse.localhost}"
check_service "Flux" "${FLUX_URL:-http://flux.localhost}"
check_service "Signal" "${SIGNAL_URL:-http://signal.localhost}"
check_service "Beacon" "${BEACON_URL:-http://beacon.localhost}"
check_service "Vision" "${VISION_URL:-http://vision.localhost}"
check_service "Sentinel" "${SENTINEL_URL:-http://sentinel.localhost}"

echo ""
echo "✅ Brainz Lab Stack is running!"
echo ""
echo "📍 Services (via Traefik):"
echo "   Vault:    ${VAULT_URL:-http://vault.localhost}"
echo "   Recall:   ${RECALL_URL:-http://recall.localhost}"
echo "   Reflex:   ${REFLEX_URL:-http://reflex.localhost}"
echo "   Pulse:    ${PULSE_URL:-http://pulse.localhost}"
echo "   Flux:     ${FLUX_URL:-http://flux.localhost}"
echo "   Signal:   ${SIGNAL_URL:-http://signal.localhost}"
echo "   Beacon:   ${BEACON_URL:-http://beacon.localhost}"
echo "   Vision:   ${VISION_URL:-http://vision.localhost}"
echo "   Sentinel: ${SENTINEL_URL:-http://sentinel.localhost}"
echo ""
echo "📊 View logs: ./scripts/logs.sh [service]"
echo "🛑 Stop:      ./scripts/stop.sh"
echo ""
