# Quick Start Guide

Get up and running with RN Agents Framework in 5 minutes.

## Prerequisites

- Node.js 18+ installed
- Git installed
- React Native development environment setup
- (Optional) Expo account for EAS builds

## Step 1: Install Framework

### Option A: Clone Repository
```bash
git clone https://github.com/Angel-Baez/rn-agents-framework.git
cd rn-agents-framework
./init-agents.sh
```

### Option B: Manual Install
```bash
# In your Expo project
mkdir -p .github/agents
cp -r path/to/framework/agents/* .github/agents/
cp -r path/to/framework/_core .github/agents/
cp project-context.yml .github/
```

## Step 2: Configure Your Project

Edit `.github/project-context.yml`:

```yaml
project:
  name: "my-app"
  type: "mobile-app"

stack:
  platform: "expo"
  expo_version: "51"

features:
  authentication: true
  offline_first: false
```

## Step 3: Use Your First Agent

Ask the orchestrator to help you:

```
@orchestrator I want to create a login screen
```

Or directly ask a specialized agent:

```
@mobile-architect Create a Button component with primary and secondary variants
```

## What's Next?

- Read the [Agent Catalog](AGENT-CATALOG.md) to understand all agents
- Check [Examples](../examples/) for complete configurations
- Review [Best Practices](CUSTOMIZATION.md) for customization

## Common First Tasks

1. **Setup Authentication**: `@backend-architect Setup Supabase authentication`
2. **Create UI Components**: `@mobile-architect Create button and input components`
3. **Setup Navigation**: `@mobile-architect Setup Expo Router with tabs`
4. **Configure Build**: `@eas-specialist Setup EAS Build`

Happy coding! 🚀
