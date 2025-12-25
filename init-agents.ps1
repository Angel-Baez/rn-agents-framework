# RN Agents Framework Installation Script
# For Windows PowerShell

param(
    [switch]$Minimal,
    [switch]$NoNative,
    [switch]$NoOffline,
    [switch]$NoAI
)

$ErrorActionPreference = "Stop"

$FrameworkDir = $PSScriptRoot
$TargetDir = ".github"

Write-Host "🚀 RN Agents Framework Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in an Expo project
if (-not (Test-Path "app.json") -and -not (Test-Path "package.json")) {
    Write-Host "⚠️  Warning: No app.json or package.json found." -ForegroundColor Yellow
    Write-Host "   This doesn't look like an Expo project." -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Create target directories
Write-Host "📁 Creating .github/agents directory..."
New-Item -ItemType Directory -Force -Path "$TargetDir\agents" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\copilot\agents" | Out-Null

# Copy core context
Write-Host "📋 Copying core context..."
Copy-Item -Path "$FrameworkDir\_core" -Destination "$TargetDir\agents\" -Recurse -Force

# Copy agents
Write-Host "🤖 Copying agents..."
if ($Minimal) {
    Write-Host "   Installing minimal agent set (6 core agents)..."
    $coreAgents = @(
        "orchestrator.md",
        "product-manager.md",
        "solution-architect.md",
        "mobile-architect.md",
        "backend-architect.md",
        "code-reviewer.md"
    )
    foreach ($agent in $coreAgents) {
        Copy-Item -Path "$FrameworkDir\agents\$agent" -Destination "$TargetDir\agents\" -Force
    }
} else {
    Write-Host "   Installing all 18 agents..."
    Copy-Item -Path "$FrameworkDir\agents\*.md" -Destination "$TargetDir\agents\" -Force
}

# Copy to both locations
Copy-Item -Path "$TargetDir\agents\*" -Destination "$TargetDir\copilot\agents\" -Recurse -Force -ErrorAction SilentlyContinue

# Copy project context template
if (-not (Test-Path "$TargetDir\project-context.yml")) {
    Write-Host "⚙️  Copying project-context.yml template..."
    Copy-Item -Path "$FrameworkDir\project-context.yml" -Destination "$TargetDir\" -Force
} else {
    Write-Host "⚠️  project-context.yml already exists, skipping..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:"
Write-Host "1. Edit .github\project-context.yml with your project details"
Write-Host "2. Start using agents with @orchestrator or @mobile-architect"
Write-Host ""
Write-Host "📚 Documentation: https://github.com/Angel-Baez/rn-agents-framework"
Write-Host ""
Write-Host "Happy coding! 🎉" -ForegroundColor Cyan
