#!/bin/bash
set -e

echo "🚀 Starting Brainz Lab Stack..."

# Check if .env exists
if [ ! -f .env ]; then
  echo "❌ .env file not found. Run ./scripts/setup.sh first"
  exit 1
fi

# Start services
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check health
echo ""
echo "🔍 Checking service health..."

check_service() {
  local name=$1
  local port=$2
  local max_attempts=30
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port/up" 2>/dev/null | grep -q "200"; then
      echo "  ✅ $name is ready"
      return 0
    fi
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "  ⚠️  $name may still be starting (check logs)"
  return 0
}

check_service "Recall" 3001
check_service "Reflex" 3002
check_service "Pulse" 3003

echo ""
echo "✅ Brainz Lab Stack is running!"
echo ""
echo "📍 Services:"
echo "   Recall:   http://localhost:3001"
echo "   Reflex:   http://localhost:3002"
echo "   Pulse:    http://localhost:3003"
echo ""
echo "📊 View logs: ./scripts/logs.sh [service]"
echo "🛑 Stop:      ./scripts/stop.sh"
echo ""
