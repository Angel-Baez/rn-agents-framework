# Customization Guide

Learn how to customize agents and add your own.

## Customizing Existing Agents

Edit agent files in `.github/agents/`:

```markdown
---
name: custom-agent
description: Your custom agent
version: 1.0.0
tags: [custom, specialized]
---

# Custom Agent

Your agent content here...
```

## Adding Custom Agents

1. Create new `.md` file in `.github/agents/`
2. Follow the agent template format
3. Update orchestrator's routing logic
4. Update `project-context.yml` to enable

## Project Context Configuration

Customize `project-context.yml` for your needs:

```yaml
project:
  name: "my-app"
  type: "mobile-app"  # or custom-type

features:
  custom_feature: true

agents_enabled:
  - orchestrator
  - your-custom-agent
```

## Best Practices

1. Keep agents focused on one responsibility
2. Document custom agents thoroughly
3. Test custom agents before deploying
4. Version your customizations

## Examples

See `/examples` directory for customization examples.
