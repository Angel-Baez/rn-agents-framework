#!/bin/bash

# RN Agents Framework Installation Script
# For macOS and Linux

set -e

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=".github"
MINIMAL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --minimal)
      MINIMAL=true
      shift
      ;;
    --no-native)
      NO_NATIVE=true
      shift
      ;;
    --no-offline)
      NO_OFFLINE=true
      shift
      ;;
    --no-ai)
      NO_AI=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🚀 RN Agents Framework Installer"
echo "================================="
echo ""

# Check if we're in an Expo project
if [ ! -f "app.json" ] && [ ! -f "package.json" ]; then
  echo "⚠️  Warning: No app.json or package.json found."
  echo "   This doesn't look like an Expo project."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Create target directory
echo "📁 Creating .github/agents directory..."
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/copilot/agents"

# Copy core context
echo "📋 Copying core context..."
cp -r "$FRAMEWORK_DIR/_core" "$TARGET_DIR/agents/"

# Copy agents
echo "🤖 Copying agents..."
if [ "$MINIMAL" = true ]; then
  echo "   Installing minimal agent set (6 core agents)..."
  cp "$FRAMEWORK_DIR/agents/orchestrator.md" "$TARGET_DIR/agents/"
  cp "$FRAMEWORK_DIR/agents/product-manager.md" "$TARGET_DIR/agents/"
  cp "$FRAMEWORK_DIR/agents/solution-architect.md" "$TARGET_DIR/agents/"
  cp "$FRAMEWORK_DIR/agents/mobile-architect.md" "$TARGET_DIR/agents/"
  cp "$FRAMEWORK_DIR/agents/backend-architect.md" "$TARGET_DIR/agents/"
  cp "$FRAMEWORK_DIR/agents/code-reviewer.md" "$TARGET_DIR/agents/"
else
  echo "   Installing all 18 agents..."
  cp "$FRAMEWORK_DIR/agents"/*.md "$TARGET_DIR/agents/"
fi

# Copy to both locations (for compatibility)
cp -r "$TARGET_DIR/agents"/* "$TARGET_DIR/copilot/agents/" 2>/dev/null || true

# Copy project context template
if [ ! -f "$TARGET_DIR/project-context.yml" ]; then
  echo "⚙️  Copying project-context.yml template..."
  cp "$FRAMEWORK_DIR/project-context.yml" "$TARGET_DIR/"
else
  echo "⚠️  project-context.yml already exists, skipping..."
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "1. Edit .github/project-context.yml with your project details"
echo "2. Start using agents with @orchestrator or @mobile-architect"
echo ""
echo "📚 Documentation: https://github.com/Angel-Baez/rn-agents-framework"
echo ""
echo "Happy coding! 🎉"
