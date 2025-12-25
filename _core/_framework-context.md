# RN Agents Framework - Core Context

## Vision

The **RN Agents Framework** is a specialized multi-agent system designed for building production-ready **React Native** applications using **Expo, TypeScript, Zustand, Supabase, and Expo Router**.

This framework empowers development teams to:
- Build scalable, performant mobile applications
- Follow mobile-first best practices
- Implement offline-first architectures
- Deploy efficiently to iOS and Android app stores
- Maintain high code quality and security standards

## Framework Principles

### 1. Mobile-First Architecture
- Design for touch interactions and mobile UX patterns
- Optimize for limited network connectivity
- Consider device resource constraints (battery, memory, CPU)
- Support both iOS and Android platforms

### 2. Performance by Default
- Minimize bundle size and startup time
- Optimize images and assets
- Use FlatList for long lists
- Implement code splitting with Expo Router
- Enable Hermes engine for better performance

### 3. Offline-First Approach
- Local-first data storage with sync capabilities
- Handle network failures gracefully
- Queue API requests when offline
- Provide clear offline/online status indicators

### 4. Developer Experience
- TypeScript for type safety
- Clear folder structure with Expo Router
- Consistent naming conventions
- Comprehensive documentation
- Easy testing setup

### 5. Security & Privacy
- Secure token storage with SecureStore
- OWASP Mobile Top 10 compliance
- Proper permission handling
- Deep linking security
- Data encryption at rest and in transit

## Tech Stack

### Core Technologies
- **Platform**: Expo SDK 51+
- **Language**: TypeScript
- **Navigation**: Expo Router (file-based routing)
- **Styling**: NativeWind (Tailwind for React Native)
- **State Management**: Zustand
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **Local Storage**: AsyncStorage, MMKV, Realm (for complex offline)

### Development Tools
- **Testing**: Jest, React Native Testing Library, Detox/Maestro
- **Build & Deploy**: EAS Build, EAS Submit, EAS Update
- **Monitoring**: Sentry, Expo Application Services
- **CI/CD**: GitHub Actions with EAS

## Architectural Patterns

### Clean Architecture for Mobile

```
app/                          # Expo Router pages
├── (tabs)/                   # Tab navigation
├── (stack)/                  # Stack navigation
└── _layout.tsx               # Root layout

src/
├── components/               # Reusable UI components
│   ├── ui/                   # Base components (Button, Input, etc.)
│   └── features/             # Feature-specific components
├── hooks/                    # Custom React hooks
├── stores/                   # Zustand stores
├── services/                 # API services (Supabase)
├── utils/                    # Helper functions
├── types/                    # TypeScript types
└── constants/                # App constants

assets/                       # Static assets
├── images/
├── fonts/
└── animations/
```

### State Management with Zustand

```typescript
// stores/userStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface UserState {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
      logout: () => set({ user: null }),
    }),
    {
      name: 'user-storage',
      storage: AsyncStorage,
    }
  )
);
```

### Supabase Integration

```typescript
// services/supabase.ts
import 'react-native-url-polyfill/auto';
import { createClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
```

### Component Structure

```typescript
// components/features/UserProfile.tsx
import { View, Text, Pressable } from 'react-native';
import { styled } from 'nativewind';

const StyledView = styled(View);
const StyledText = styled(Text);
const StyledPressable = styled(Pressable);

interface UserProfileProps {
  name: string;
  onPress: () => void;
}

export function UserProfile({ name, onPress }: UserProfileProps) {
  return (
    <StyledView className="p-4 bg-white rounded-lg">
      <StyledText className="text-lg font-bold">{name}</StyledText>
      <StyledPressable 
        onPress={onPress}
        className="mt-2 p-2 bg-blue-500 rounded"
      >
        <StyledText className="text-white text-center">View Profile</StyledText>
      </StyledPressable>
    </StyledView>
  );
}
```

## Code Conventions

### File Naming
- **Components**: PascalCase (`UserProfile.tsx`)
- **Hooks**: camelCase with `use` prefix (`useAuth.ts`)
- **Stores**: camelCase with Store suffix (`userStore.ts`)
- **Services**: camelCase (`supabase.ts`, `api.ts`)
- **Types**: PascalCase (`User.ts`, `types.ts`)
- **Utils**: camelCase (`formatDate.ts`)

### Folder Structure with Expo Router
- Use `(group)` for navigation groups without path segments
- Use `_layout.tsx` for nested layouts
- Use `[param]` for dynamic routes
- Use `(tabs)` for tab navigation
- Use `(stack)` for stack navigation

### Import Order
1. React and React Native imports
2. Third-party libraries
3. Components
4. Hooks
5. Stores
6. Services
7. Utils and constants
8. Types

```typescript
import React, { useState } from 'react';
import { View, Text } from 'react-native';
import { useRouter } from 'expo-router';
import { Button } from '@/components/ui/Button';
import { useAuth } from '@/hooks/useAuth';
import { useUserStore } from '@/stores/userStore';
import { supabase } from '@/services/supabase';
import { formatDate } from '@/utils/date';
import type { User } from '@/types/User';
```

## Performance Best Practices

### 1. Image Optimization
- Use Expo Image for automatic optimization
- Implement lazy loading for images
- Use appropriate image formats (WebP when possible)
- Cache images locally

### 2. List Performance
- Use `FlatList` or `FlashList` for long lists
- Implement proper `keyExtractor`
- Use `getItemLayout` for fixed-height items
- Set `removeClippedSubviews={true}`

### 3. Bundle Size
- Use dynamic imports for large features
- Implement code splitting with Expo Router
- Analyze bundle with `npx expo export --dump-sourcemap`
- Remove unused dependencies

### 4. Rendering Optimization
- Use `React.memo` for expensive components
- Implement `useMemo` and `useCallback` appropriately
- Avoid inline functions in render
- Use Zustand selectors to prevent unnecessary re-renders

## Testing Strategy

### Unit Tests (Jest)
```typescript
// __tests__/utils/formatDate.test.ts
import { formatDate } from '@/utils/formatDate';

describe('formatDate', () => {
  it('formats date correctly', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date)).toBe('January 15, 2024');
  });
});
```

### Component Tests (React Native Testing Library)
```typescript
// __tests__/components/Button.test.tsx
import { render, fireEvent } from '@testing-library/react-native';
import { Button } from '@/components/ui/Button';

describe('Button', () => {
  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    const { getByText } = render(<Button onPress={onPress}>Click me</Button>);
    
    fireEvent.press(getByText('Click me'));
    expect(onPress).toHaveBeenCalledTimes(1);
  });
});
```

### E2E Tests (Detox/Maestro)
```yaml
# e2e/flows/login.yaml
appId: com.yourapp
---
- launchApp
- tapOn: "Email"
- inputText: "user@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"
- assertVisible: "Welcome"
```

## Security Guidelines

### 1. Secure Storage
```typescript
import * as SecureStore from 'expo-secure-store';

// Store tokens securely
await SecureStore.setItemAsync('authToken', token);
const token = await SecureStore.getItemAsync('authToken');
```

### 2. API Security
- Always use HTTPS
- Implement Row Level Security (RLS) in Supabase
- Validate inputs on both client and server
- Use environment variables for sensitive data
- Never commit API keys to version control

### 3. Permission Handling
```typescript
import * as Location from 'expo-location';

const { status } = await Location.requestForegroundPermissionsAsync();
if (status !== 'granted') {
  Alert.alert('Permission denied', 'Location permission is required');
  return;
}
```

## Deployment Strategy

### EAS Build Configuration
```json
// eas.json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": { "buildType": "apk" }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "your-apple-id", "ascAppId": "your-asc-app-id" },
      "android": { "serviceAccountKeyPath": "./service-account.json" }
    }
  }
}
```

### Over-The-Air Updates
```typescript
import * as Updates from 'expo-updates';

async function checkForUpdates() {
  const update = await Updates.checkForUpdateAsync();
  if (update.isAvailable) {
    await Updates.fetchUpdateAsync();
    await Updates.reloadAsync();
  }
}
```

## Agent Collaboration

Agents in this framework work together following these principles:

1. **Orchestrator** routes requests to specialized agents
2. **Architects** make high-level technical decisions
3. **Engineers** implement specific features
4. **Quality agents** ensure code quality and security
5. **Operations agents** handle deployment and monitoring

All agents share this context and follow these conventions to ensure consistency across the codebase.

## Resources

- [Expo Documentation](https://docs.expo.dev)
- [React Native Documentation](https://reactnative.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Zustand Documentation](https://docs.pmnd.rs/zustand)
- [NativeWind Documentation](https://www.nativewind.dev)
- [Expo Router Documentation](https://docs.expo.dev/router/introduction)
