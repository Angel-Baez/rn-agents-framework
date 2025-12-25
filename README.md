# 🚀 RN Agents Framework

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)

**A comprehensive multi-agent framework for building production-ready React Native mobile applications**

Specialized agents for **Expo + TypeScript + Zustand + Supabase + Expo Router**

[Quick Start](#-quick-start) • [Agent Catalog](#-agent-catalog) • [Documentation](#-documentation) • [Examples](#-examples)

</div>

---

## 📖 Overview

The **RN Agents Framework** is a specialized multi-agent system designed for building scalable, performant React Native applications. It provides **18 specialized AI agents** that handle everything from architecture to deployment, following mobile-first best practices.

### Why This Framework?

- ⚡ **Mobile-First**: Optimized for React Native and Expo
- 🎯 **Specialized Agents**: 18 expert agents for every aspect of development
- 📱 **Cross-Platform**: Build for iOS and Android simultaneously
- 🔒 **Security Built-In**: OWASP Mobile Top 10 compliance
- 📴 **Offline-First**: Handle intermittent connectivity gracefully
- 🚀 **Production-Ready**: Best practices from day one

---

## 🏗️ Tech Stack

```yaml
Platform: Expo SDK 51+
Language: TypeScript
Navigation: Expo Router (file-based)
Styling: NativeWind (Tailwind for RN)
State: Zustand
Backend: Supabase (PostgreSQL, Auth, Storage)
Storage: AsyncStorage, MMKV, Realm (optional)
Deployment: EAS Build, EAS Submit, EAS Update
```

---

## 🚀 Quick Start

### Method 1: Bash Script (Recommended for macOS/Linux)

```bash
# Clone the repository
git clone https://github.com/Angel-Baez/rn-agents-framework.git
cd rn-agents-framework

# Run the installation script
chmod +x init-agents.sh
./init-agents.sh

# Or for minimal setup (6 core agents only)
./init-agents.sh --minimal
```

### Method 2: PowerShell (Windows)

```powershell
# Clone the repository
git clone https://github.com/Angel-Baez/rn-agents-framework.git
cd rn-agents-framework

# Run the installation script
.\init-agents.ps1

# Or for minimal setup
.\init-agents.ps1 -Minimal
```

### Method 3: Manual Setup

```bash
# 1. Copy agents to your project
cp -r agents/ .github/agents/
cp -r _core/ .github/agents/_core/

# 2. Copy project context template
cp project-context.yml .github/project-context.yml

# 3. Configure your project
# Edit .github/project-context.yml with your app details
```

---

## 🤖 Agent Catalog

### Core Agents (5)

| Agent | Role | When to Use |
|-------|------|-------------|
| **orchestrator** | Central router & coordinator | Entry point for all requests |
| **product-manager** | Requirements & user stories | Defining features |
| **solution-architect** | Architecture & ADRs | Technical decisions |
| **code-reviewer** | Code quality & standards | Code reviews |
| **documentation-engineer** | Technical documentation | Writing docs |

### Mobile Development (3)

| Agent | Role | When to Use |
|-------|------|-------------|
| **mobile-architect** | UI/UX & components | Building screens & components |
| **backend-architect** | APIs & Supabase | Backend integration |
| **data-engineer** | Database & storage | Data modeling |

### Mobile-Specific (4) ⭐ NEW

| Agent | Role | When to Use |
|-------|------|-------------|
| **native-modules-engineer** | Expo SDK & permissions | Camera, location, notifications |
| **performance-optimizer** | Performance & bundle size | Optimizations |
| **eas-specialist** | Build & deployment | EAS Build/Submit/Update |
| **offline-architect** | Offline-first features | Sync strategies |

### Quality & Security (2)

| Agent | Role | When to Use |
|-------|------|-------------|
| **security-guardian** | Security & OWASP | Security reviews |
| **test-engineer** | Testing & coverage | Writing tests |

### Operations (4)

| Agent | Role | When to Use |
|-------|------|-------------|
| **qa-lead** | Manual testing | Device testing |
| **observability-engineer** | Monitoring & analytics | Sentry, analytics |
| **release-manager** | Releases & versioning | App store submissions |
| **ai-integration-engineer** | AI features | AI/ML integration |

---

## 💼 Specialized Templates

Choose a template that matches your app type for additional optimizations:

- **fitness-app-specialist**: Health tracking, Apple Health/Google Fit integration
- **social-app-specialist**: Real-time messaging, feeds, notifications
- **ecommerce-mobile-specialist**: Shopping cart, Stripe payments, product catalog
- **fintech-app-specialist**: Banking features, enhanced security, transactions

```yaml
# In project-context.yml
project:
  type: "fitness-app"  # or social-app, ecommerce-app, fintech-app
```

---

## 📂 Recommended Project Structure

```
my-expo-app/
├── app/                          # Expo Router pages
│   ├── (tabs)/                   # Tab navigation
│   │   ├── _layout.tsx
│   │   ├── index.tsx
│   │   └── profile.tsx
│   ├── (stack)/                  # Stack navigation
│   │   └── details.tsx
│   ├── _layout.tsx               # Root layout
│   └── index.tsx                 # Entry screen
├── src/
│   ├── components/               # Reusable components
│   │   ├── ui/                   # Base UI components
│   │   └── features/             # Feature components
│   ├── hooks/                    # Custom hooks
│   ├── stores/                   # Zustand stores
│   ├── services/                 # API services
│   │   ├── supabase.ts
│   │   └── api/
│   ├── utils/                    # Utility functions
│   ├── types/                    # TypeScript types
│   └── constants/                # App constants
├── assets/                       # Images, fonts, etc.
├── .github/
│   ├── agents/                   # AI agents (framework)
│   └── project-context.yml       # Project configuration
├── eas.json                      # EAS Build configuration
├── app.json                      # Expo configuration
└── package.json
```

---

## 🎯 How to Use Agents

### 1. Ask the Orchestrator

The **orchestrator** is your entry point. It routes requests to specialized agents:

```
"I want to add a login screen with email and password"

→ Orchestrator routes to:
  1. @mobile-architect (UI components)
  2. @backend-architect (auth API)
  3. @security-guardian (security review)
```

### 2. Direct Agent Requests

If you know which agent you need, address them directly:

```
@mobile-architect Create a Button component with NativeWind styling

@backend-architect Set up Supabase authentication with email/password

@native-modules-engineer Integrate expo-camera with permission handling
```

### 3. Multi-Agent Workflows

For complex features, multiple agents collaborate:

```
Feature: Profile picture upload

1. @product-manager - Define requirements
2. @solution-architect - Create ADR
3. @native-modules-engineer - Setup image picker
4. @mobile-architect - Build UI
5. @backend-architect - Upload API
6. @security-guardian - Security review
7. @test-engineer - Write tests
```

---

## 📚 Documentation

Comprehensive documentation available in `/docs`:

- **[QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[AGENT-CATALOG.md](docs/AGENT-CATALOG.md)** - Detailed agent descriptions
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** - Customize agents
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues
- **[MIGRATION-FROM-MERN.md](docs/MIGRATION-FROM-MERN.md)** - Migrate from MERN framework

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by [mern-agents-framework](https://github.com/Angel-Baez/mern-agents-framework)
- Built for the React Native and Expo community
- Powered by GitHub Copilot

---

<div align="center">

**Built with ❤️ for the React Native community**

⭐ Star this repo if you find it helpful!

</div>
