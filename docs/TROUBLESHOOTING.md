# Troubleshooting Guide

Common issues and solutions.

## Installation Issues

### Agents not found
**Problem**: GitHub Copilot can't find agents
**Solution**: Ensure agents are in `.github/agents/` or `.github/copilot/agents/`

### Permission denied
**Problem**: Can't run init-agents.sh
**Solution**: `chmod +x init-agents.sh`

## Expo/EAS Issues

### EAS Build failing
**Problem**: Build fails on EAS
**Solution**: Check `eas.json` configuration, verify credentials

### OTA updates not working
**Problem**: EAS Update not reaching devices
**Solution**: Verify runtime version, check update channel

## Supabase Issues

### Connection errors
**Problem**: Can't connect to Supabase
**Solution**: Check environment variables, verify API keys

### RLS policies blocking
**Problem**: Can't read/write data
**Solution**: Review Row Level Security policies

## Performance Issues

### Slow app startup
**Problem**: App takes too long to start
**Solution**: Enable Hermes, optimize imports, lazy load features

### Large bundle size
**Problem**: App bundle exceeds 50MB
**Solution**: Remove unused dependencies, use code splitting

## Testing Issues

### Tests failing
**Problem**: Jest tests not passing
**Solution**: Check test configuration, mock native modules

## Getting Help

1. Check [GitHub Issues](https://github.com/Angel-Baez/rn-agents-framework/issues)
2. Read [Documentation](README.md)
3. Ask in [Discussions](https://github.com/Angel-Baez/rn-agents-framework/discussions)
