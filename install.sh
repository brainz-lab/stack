#!/bin/bash
# Brainz Lab Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/brainz-lab/stack/main/install.sh | bash

set -e

REPO="brainz-lab/stack"
INSTALL_DIR="${BRAINZLAB_INSTALL_DIR:-$HOME/brainzlab}"

echo ""
echo "🧠 Brainz Lab Installer"
echo "======================="
echo ""

# Check requirements
echo "Checking requirements..."

if ! command -v docker &> /dev/null; then
  echo "❌ Docker is required. Install from https://docker.com"
  exit 1
fi
echo "  ✅ Docker installed"

if ! command -v git &> /dev/null; then
  echo "❌ Git is required"
  exit 1
fi
echo "  ✅ Git installed"

# Create install directory
echo ""
echo "📁 Installing to: $INSTALL_DIR"

if [ -d "$INSTALL_DIR" ]; then
  echo "  Directory exists, updating..."
  cd "$INSTALL_DIR"
  git pull origin main 2>/dev/null || true
else
  git clone "https://github.com/$REPO.git" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

# Run setup
echo ""
./scripts/setup.sh

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To start Brainz Lab:"
echo "  cd $INSTALL_DIR"
echo "  ./scripts/start.sh"
echo ""
echo "To add to your Rails app:"
echo "  gem 'brainzlab'"
echo ""
echo "  # config/initializers/brainzlab.rb"
echo "  BrainzLab.configure do |config|"
echo "    config.secret_key = ENV['BRAINZLAB_SECRET_KEY']"
echo "    config.recall_url = ENV['RECALL_URL']  # http://recall.localhost or https://recall.yourdomain.com"
echo "    config.reflex_url = ENV['REFLEX_URL']  # http://reflex.localhost or https://reflex.yourdomain.com"
echo "    config.pulse_url  = ENV['PULSE_URL']   # http://pulse.localhost or https://pulse.yourdomain.com"
echo "  end"
echo ""
echo "💡 Tip: Run './scripts/setup.sh' to configure URLs and optionally export them globally."
echo ""
