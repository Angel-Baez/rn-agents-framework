# SOLID Principles for Mobile Development

## Overview

SOLID principles are fundamental to building maintainable, scalable React Native applications. This guide adapts these principles specifically for mobile development with Expo, TypeScript, and React Native.

## 1. Single Responsibility Principle (SRP)

**Definition**: A component, hook, or module should have one, and only one, reason to change.

### Mobile Context

In React Native, this means:
- Components should do one thing well
- Hooks should handle one specific concern
- Services should manage one domain
- Stores should manage one slice of state

### ✅ Good Example

```typescript
// components/ui/Button.tsx - Only handles button rendering
interface ButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
}

export function Button({ onPress, children, variant = 'primary' }: ButtonProps) {
  const styles = variant === 'primary' 
    ? 'bg-blue-500 text-white' 
    : 'bg-gray-200 text-black';
  
  return (
    <Pressable onPress={onPress} className={`p-3 rounded ${styles}`}>
      <Text className="text-center font-semibold">{children}</Text>
    </Pressable>
  );
}

// hooks/useAuth.ts - Only handles authentication logic
export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const { data } = supabase.auth.onAuthStateChange((event, session) => {
      setUser(session?.user ?? null);
      setLoading(false);
    });
    return () => data.subscription.unsubscribe();
  }, []);

  return { user, loading };
}

// services/api/users.ts - Only handles user API calls
export const userService = {
  async getUser(id: string) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  },
  
  async updateUser(id: string, updates: Partial<User>) {
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  },
};
```

### ❌ Bad Example

```typescript
// UserProfile.tsx - Does too many things!
export function UserProfile() {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  
  // Fetching data
  useEffect(() => {
    async function fetchData() {
      const userData = await fetch('/api/user');
      const postsData = await fetch('/api/posts');
      setUser(await userData.json());
      setPosts(await postsData.json());
      setLoading(false);
    }
    fetchData();
  }, []);
  
  // Rendering profile AND posts AND handling errors AND navigation
  return (
    <ScrollView>
      {loading ? <ActivityIndicator /> : (
        <>
          <View>{/* User profile UI */}</View>
          <View>{/* Posts list UI */}</View>
          <View>{/* Comments UI */}</View>
        </>
      )}
    </ScrollView>
  );
}
```

## 2. Open/Closed Principle (OCP)

**Definition**: Software entities should be open for extension, but closed for modification.

### Mobile Context

Use composition, hooks, and higher-order components to extend functionality without modifying existing code.

### ✅ Good Example

```typescript
// components/ui/Card.tsx - Base component
interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export function Card({ children, className = '' }: CardProps) {
  return (
    <View className={`bg-white rounded-lg shadow-md p-4 ${className}`}>
      {children}
    </View>
  );
}

// components/features/UserCard.tsx - Extended without modifying Card
export function UserCard({ user }: { user: User }) {
  return (
    <Card>
      <Image source={{ uri: user.avatar }} className="w-16 h-16 rounded-full" />
      <Text className="text-lg font-bold mt-2">{user.name}</Text>
      <Text className="text-gray-600">{user.email}</Text>
    </Card>
  );
}

// components/features/ProductCard.tsx - Another extension
export function ProductCard({ product }: { product: Product }) {
  return (
    <Card>
      <Image source={{ uri: product.image }} className="w-full h-48" />
      <Text className="text-xl font-bold">{product.name}</Text>
      <Text className="text-green-600">${product.price}</Text>
    </Card>
  );
}
```

### Using Hooks for Extension

```typescript
// hooks/useApiRequest.ts - Base hook
export function useApiRequest<T>(fetcher: () => Promise<T>) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const execute = async () => {
    try {
      setLoading(true);
      const result = await fetcher();
      setData(result);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, execute };
}

// hooks/useUser.ts - Extended functionality
export function useUser(userId: string) {
  return useApiRequest(() => userService.getUser(userId));
}

// hooks/useUserWithCache.ts - Further extension
export function useUserWithCache(userId: string) {
  const result = useUser(userId);
  
  useEffect(() => {
    if (result.data) {
      AsyncStorage.setItem(`user-${userId}`, JSON.stringify(result.data));
    }
  }, [result.data, userId]);
  
  return result;
}
```

## 3. Liskov Substitution Principle (LSP)

**Definition**: Objects of a superclass should be replaceable with objects of a subclass without breaking the application.

### Mobile Context

Components accepting a base type should work with any derived type without unexpected behavior.

### ✅ Good Example

```typescript
// types/Button.ts
interface BaseButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

// components/ui/Button.tsx
export function Button({ onPress, children, disabled }: BaseButtonProps) {
  return (
    <Pressable 
      onPress={onPress} 
      disabled={disabled}
      className={`p-3 rounded ${disabled ? 'opacity-50' : ''}`}
    >
      <Text>{children}</Text>
    </Pressable>
  );
}

// components/ui/IconButton.tsx - Can substitute Button
interface IconButtonProps extends BaseButtonProps {
  icon: string;
}

export function IconButton({ onPress, children, icon, disabled }: IconButtonProps) {
  return (
    <Pressable 
      onPress={onPress} 
      disabled={disabled}
      className={`p-3 rounded flex-row items-center ${disabled ? 'opacity-50' : ''}`}
    >
      <Ionicons name={icon} size={20} />
      <Text className="ml-2">{children}</Text>
    </Pressable>
  );
}

// Usage - Both work the same way
<Button onPress={handleSubmit}>Submit</Button>
<IconButton icon="checkmark" onPress={handleSubmit}>Submit</IconButton>
```

## 4. Interface Segregation Principle (ISP)

**Definition**: No client should be forced to depend on interfaces it doesn't use.

### Mobile Context

Create focused, minimal prop interfaces. Don't force components to accept props they don't need.

### ✅ Good Example

```typescript
// Separate, focused interfaces
interface Identifiable {
  id: string;
}

interface Displayable {
  title: string;
  description: string;
}

interface Touchable {
  onPress: () => void;
}

// Components use only what they need
interface ListItemProps extends Identifiable, Displayable {
  // Only requires id, title, description
}

export function ListItem({ id, title, description }: ListItemProps) {
  return (
    <View key={id} className="p-4 border-b border-gray-200">
      <Text className="font-bold">{title}</Text>
      <Text className="text-gray-600">{description}</Text>
    </View>
  );
}

interface InteractiveListItemProps extends ListItemProps, Touchable {
  // Adds onPress only when needed
}

export function InteractiveListItem({ 
  id, 
  title, 
  description, 
  onPress 
}: InteractiveListItemProps) {
  return (
    <Pressable onPress={onPress} className="p-4 border-b border-gray-200">
      <Text className="font-bold">{title}</Text>
      <Text className="text-gray-600">{description}</Text>
    </Pressable>
  );
}
```

### ❌ Bad Example

```typescript
// Fat interface - forces unnecessary props
interface ListItemProps {
  id: string;
  title: string;
  description: string;
  onPress: () => void;        // Not always needed!
  onLongPress: () => void;    // Not always needed!
  icon: string;               // Not always needed!
  badge: number;              // Not always needed!
}

// Component forced to accept all props even if unused
export function SimpleListItem(props: ListItemProps) {
  // Only uses id, title, description but must accept everything
  return <View>...</View>;
}
```

## 5. Dependency Inversion Principle (DIP)

**Definition**: High-level modules should not depend on low-level modules. Both should depend on abstractions.

### Mobile Context

Use dependency injection, abstract services, and configuration to decouple components from specific implementations.

### ✅ Good Example

```typescript
// types/storage.ts - Abstract interface
export interface StorageService {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
}

// services/asyncStorage.ts - Implementation 1
import AsyncStorage from '@react-native-async-storage/async-storage';

export const asyncStorageService: StorageService = {
  getItem: (key) => AsyncStorage.getItem(key),
  setItem: (key, value) => AsyncStorage.setItem(key, value),
  removeItem: (key) => AsyncStorage.removeItem(key),
};

// services/secureStorage.ts - Implementation 2
import * as SecureStore from 'expo-secure-store';

export const secureStorageService: StorageService = {
  getItem: (key) => SecureStore.getItemAsync(key),
  setItem: (key, value) => SecureStore.setItemAsync(key, value),
  removeItem: (key) => SecureStore.deleteItemAsync(key),
};

// hooks/useStorage.ts - Depends on abstraction, not implementation
export function useStorage(storage: StorageService) {
  const [value, setValue] = useState<string | null>(null);

  const save = async (key: string, data: string) => {
    await storage.setItem(key, data);
    setValue(data);
  };

  const load = async (key: string) => {
    const data = await storage.getItem(key);
    setValue(data);
    return data;
  };

  return { value, save, load };
}

// Usage - Can inject any storage implementation
function UserSettings() {
  const { value, save, load } = useStorage(asyncStorageService);
  // or
  const { value, save, load } = useStorage(secureStorageService);
}
```

### API Service Abstraction

```typescript
// types/api.ts
export interface ApiClient {
  get<T>(url: string): Promise<T>;
  post<T>(url: string, data: unknown): Promise<T>;
  put<T>(url: string, data: unknown): Promise<T>;
  delete<T>(url: string): Promise<T>;
}

// services/supabaseClient.ts
export const supabaseApiClient: ApiClient = {
  async get<T>(table: string): Promise<T> {
    const { data, error } = await supabase.from(table).select('*');
    if (error) throw error;
    return data as T;
  },
  async post<T>(table: string, data: unknown): Promise<T> {
    const { data: result, error } = await supabase.from(table).insert(data).single();
    if (error) throw error;
    return result as T;
  },
  // ... other methods
};

// hooks/useApi.ts - Depends on abstraction
export function useApi(client: ApiClient) {
  const fetchData = async <T>(endpoint: string) => {
    return await client.get<T>(endpoint);
  };
  
  return { fetchData };
}
```

## Mobile-Specific SOLID Applications

### State Management (Zustand)

```typescript
// stores/authStore.ts - Single responsibility
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));

// stores/cartStore.ts - Separate concern
export const useCartStore = create<CartState>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({ 
    items: state.items.filter(i => i.id !== id) 
  })),
}));
```

### Navigation with Expo Router

```typescript
// app/_layout.tsx - Configuration layer
export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
    </Stack>
  );
}

// app/(tabs)/_layout.tsx - Tabs configuration
export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Home' }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile' }} />
    </Tabs>
  );
}
```

## Summary

Applying SOLID principles in React Native development:

1. **SRP**: Keep components, hooks, and services focused on a single responsibility
2. **OCP**: Use composition and hooks to extend functionality without modification
3. **LSP**: Ensure component variants can substitute their base types
4. **ISP**: Create minimal, focused prop interfaces
5. **DIP**: Depend on abstractions (interfaces) rather than concrete implementations

Following these principles leads to:
- More maintainable code
- Easier testing
- Better reusability
- Clearer architecture
- Smoother team collaboration
