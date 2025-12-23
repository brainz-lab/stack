#!/bin/bash

echo "⚠️  This will DELETE all data (databases, volumes)."
read -p "Are you sure? (y/N) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Cancelled"
  exit 0
fi

echo "🗑️  Removing containers and volumes..."
docker-compose down -v

echo "✅ All data reset. Run ./scripts/start.sh to start fresh."
