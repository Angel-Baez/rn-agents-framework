# Migration from MERN Framework

Guide for teams migrating from mern-agents-framework.

## Key Differences

| Aspect | MERN Framework | RN Framework |
|--------|----------------|--------------|
| Platform | Web (React) | Mobile (React Native) |
| Navigation | React Router | Expo Router |
| Styling | Tailwind CSS | NativeWind |
| Backend | Express + MongoDB | Supabase |
| State | Redux/Zustand | Zustand |
| Deployment | Vercel/Netlify | EAS Build/Submit |

## Agent Mapping

### Renamed Agents
- `frontend-architect` → `mobile-architect`
- No change for: orchestrator, product-manager, solution-architect

### New Mobile-Specific Agents
- `native-modules-engineer` (NEW)
- `performance-optimizer` (NEW)
- `eas-specialist` (NEW)
- `offline-architect` (NEW)

## Migration Steps

### 1. Update Stack
```yaml
# Old (MERN)
stack:
  frontend: "react"
  backend: "express"
  database: "mongodb"

# New (RN)
stack:
  platform: "expo"
  backend: "supabase"
  navigation: "expo-router"
```

### 2. Update Agent References
Replace references to `frontend-architect` with `mobile-architect`

### 3. Add Mobile Configuration
```yaml
platforms:
  ios:
    min_version: "13.0"
  android:
    min_version: "21"
```

### 4. Configure EAS
Replace Vercel config with `eas.json`

## Code Migration

### Components
```typescript
// MERN (Web)
<div className="bg-blue-500">
  <h1>Title</h1>
</div>

// RN (Mobile)
<View className="bg-blue-500">
  <Text className="text-xl">Title</Text>
</View>
```

### API Calls
```typescript
// MERN (Express)
fetch('/api/users')

// RN (Supabase)
supabase.from('users').select('*')
```

## Best Practices

1. **Test on Real Devices**: Unlike web, mobile needs device testing
2. **Handle Offline**: Mobile apps must work offline
3. **Optimize Images**: Mobile has limited bandwidth
4. **Request Permissions**: Always explain why you need permissions

## Need Help?

Join our community discussions for migration support.
