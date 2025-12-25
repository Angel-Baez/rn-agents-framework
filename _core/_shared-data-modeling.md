# Data Modeling Best Practices for Mobile Apps

## Overview

Effective data modeling is crucial for building performant, scalable React Native applications with Supabase. This guide covers data modeling strategies optimized for mobile development, including offline-first scenarios, sync patterns, and performance optimization.

## Core Principles

### 1. Mobile-First Data Design
- Minimize data transfer over the network
- Design for offline scenarios
- Consider device storage limitations
- Optimize for quick reads over complex queries

### 2. Sync-Friendly Models
- Include timestamps for conflict resolution
- Use UUIDs for client-generated IDs
- Design for eventual consistency
- Handle partial sync states

### 3. Performance Optimization
- Denormalize when appropriate for mobile
- Use pagination for large datasets
- Implement efficient caching strategies
- Minimize foreign key lookups

## Database Schema Design

### User Management

```sql
-- users table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read all profiles but only update their own
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);
```

### Posts with Offline Support

```sql
-- posts table with sync metadata
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  
  -- Sync metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT false,
  
  -- Denormalized data for performance
  author_name TEXT,
  author_avatar TEXT,
  comments_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0
);

-- Indexes for mobile queries
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_posts_status ON public.posts(status);
CREATE INDEX idx_posts_updated_at ON public.posts(updated_at DESC);
CREATE INDEX idx_posts_sync ON public.posts(synced_at) WHERE is_deleted = false;

-- RLS policies
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view published posts"
  ON public.posts FOR SELECT
  USING (status = 'published' OR user_id = auth.uid());

CREATE POLICY "Users can create own posts"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON public.posts FOR UPDATE
  USING (auth.uid() = user_id);
```

### Relationships with Comments

```sql
-- comments table
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  parent_comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT false,
  
  -- Denormalized for performance
  author_name TEXT,
  author_avatar TEXT
);

-- Indexes
CREATE INDEX idx_comments_post_id ON public.comments(post_id);
CREATE INDEX idx_comments_user_id ON public.comments(user_id);
CREATE INDEX idx_comments_parent ON public.comments(parent_comment_id);

-- Trigger to update denormalized counts
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts 
    SET comments_count = comments_count + 1 
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts 
    SET comments_count = GREATEST(comments_count - 1, 0)
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_comments_count
AFTER INSERT OR DELETE ON public.comments
FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();
```

## TypeScript Types

### Type Definitions

```typescript
// types/database.ts
export interface Database {
  public: {
    Tables: {
      users: {
        Row: User;
        Insert: Omit<User, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<User, 'id' | 'created_at'>>;
      };
      posts: {
        Row: Post;
        Insert: Omit<Post, 'id' | 'created_at' | 'updated_at' | 'synced_at'>;
        Update: Partial<Omit<Post, 'id' | 'created_at'>>;
      };
      comments: {
        Row: Comment;
        Insert: Omit<Comment, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<Comment, 'id' | 'created_at'>>;
      };
    };
  };
}

// types/models.ts
export interface User {
  id: string;
  email: string;
  display_name: string | null;
  avatar_url: string | null;
  bio: string | null;
  created_at: string;
  updated_at: string;
  last_seen_at: string;
}

export interface Post {
  id: string;
  user_id: string;
  title: string;
  content: string;
  image_url: string | null;
  status: 'draft' | 'published' | 'archived';
  created_at: string;
  updated_at: string;
  synced_at: string;
  is_deleted: boolean;
  
  // Denormalized fields
  author_name: string | null;
  author_avatar: string | null;
  comments_count: number;
  likes_count: number;
}

export interface Comment {
  id: string;
  post_id: string;
  user_id: string;
  content: string;
  parent_comment_id: string | null;
  created_at: string;
  updated_at: string;
  is_deleted: boolean;
  
  // Denormalized fields
  author_name: string | null;
  author_avatar: string | null;
}
```

## Local Storage Models

### AsyncStorage Schema

```typescript
// types/localStorage.ts
export interface LocalStorageSchema {
  // User session
  'user:current': User;
  'auth:token': string;
  
  // Offline queue
  'sync:queue': SyncQueueItem[];
  
  // Cached data
  'cache:posts': Post[];
  'cache:user-profile': Record<string, User>;
  
  // App settings
  'settings:theme': 'light' | 'dark';
  'settings:notifications': boolean;
  
  // Last sync timestamps
  'sync:last-posts': string;
  'sync:last-comments': string;
}

export interface SyncQueueItem {
  id: string;
  type: 'create' | 'update' | 'delete';
  table: 'posts' | 'comments' | 'users';
  data: unknown;
  timestamp: string;
  retryCount: number;
}
```

### Storage Service

```typescript
// services/localStorage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

export const localStorage = {
  async get<K extends keyof LocalStorageSchema>(
    key: K
  ): Promise<LocalStorageSchema[K] | null> {
    try {
      const value = await AsyncStorage.getItem(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error(`Error reading ${key}:`, error);
      return null;
    }
  },

  async set<K extends keyof LocalStorageSchema>(
    key: K,
    value: LocalStorageSchema[K]
  ): Promise<void> {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error writing ${key}:`, error);
    }
  },

  async remove(key: keyof LocalStorageSchema): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error(`Error removing ${key}:`, error);
    }
  },

  async clear(): Promise<void> {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('Error clearing storage:', error);
    }
  },
};
```

## Data Access Patterns

### Service Layer

```typescript
// services/api/posts.ts
import { supabase } from '@/services/supabase';
import type { Post } from '@/types/models';

export const postsService = {
  // Fetch with pagination
  async getPosts(page = 0, limit = 20): Promise<Post[]> {
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .eq('status', 'published')
      .eq('is_deleted', false)
      .order('created_at', { ascending: false })
      .range(page * limit, (page + 1) * limit - 1);

    if (error) throw error;
    return data || [];
  },

  // Fetch single post with comments
  async getPostWithComments(postId: string): Promise<Post & { comments: Comment[] }> {
    const { data, error } = await supabase
      .from('posts')
      .select(`
        *,
        comments:comments(*)
      `)
      .eq('id', postId)
      .single();

    if (error) throw error;
    return data;
  },

  // Create post (works offline with queue)
  async createPost(post: Omit<Post, 'id' | 'created_at' | 'updated_at'>): Promise<Post> {
    const { data, error } = await supabase
      .from('posts')
      .insert(post)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Update post
  async updatePost(id: string, updates: Partial<Post>): Promise<Post> {
    const { data, error } = await supabase
      .from('posts')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Soft delete
  async deletePost(id: string): Promise<void> {
    const { error } = await supabase
      .from('posts')
      .update({ is_deleted: true, updated_at: new Date().toISOString() })
      .eq('id', id);

    if (error) throw error;
  },

  // Sync changes since last sync
  async syncSince(lastSyncTime: string): Promise<Post[]> {
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .gt('updated_at', lastSyncTime)
      .order('updated_at', { ascending: true });

    if (error) throw error;
    return data || [];
  },
};
```

### Repository Pattern for Offline

```typescript
// services/repositories/postRepository.ts
import { localStorage } from '@/services/localStorage';
import { postsService } from '@/services/api/posts';
import NetInfo from '@react-native-community/netinfo';

export const postRepository = {
  // Get posts (from cache or network)
  async getPosts(forceRefresh = false): Promise<Post[]> {
    const isConnected = await NetInfo.fetch().then(state => state.isConnected);

    if (!isConnected || !forceRefresh) {
      const cached = await localStorage.get('cache:posts');
      if (cached) return cached;
    }

    if (isConnected) {
      const posts = await postsService.getPosts();
      await localStorage.set('cache:posts', posts);
      return posts;
    }

    return [];
  },

  // Create post (queue if offline)
  async createPost(post: Omit<Post, 'id' | 'created_at' | 'updated_at'>): Promise<Post> {
    const isConnected = await NetInfo.fetch().then(state => state.isConnected);

    if (isConnected) {
      return await postsService.createPost(post);
    } else {
      // Queue for later sync
      const tempPost: Post = {
        ...post,
        id: `temp-${Date.now()}`,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        synced_at: new Date().toISOString(),
        is_deleted: false,
        comments_count: 0,
        likes_count: 0,
      };

      const queue = await localStorage.get('sync:queue') || [];
      queue.push({
        id: tempPost.id,
        type: 'create',
        table: 'posts',
        data: post,
        timestamp: new Date().toISOString(),
        retryCount: 0,
      });
      await localStorage.set('sync:queue', queue);

      return tempPost;
    }
  },

  // Sync pending changes
  async syncPendingChanges(): Promise<void> {
    const queue = await localStorage.get('sync:queue') || [];
    const results = [];

    for (const item of queue) {
      try {
        if (item.type === 'create' && item.table === 'posts') {
          await postsService.createPost(item.data as any);
        } else if (item.type === 'update' && item.table === 'posts') {
          await postsService.updatePost(item.id, item.data as any);
        }
        results.push(item.id);
      } catch (error) {
        console.error(`Failed to sync ${item.id}:`, error);
        item.retryCount++;
      }
    }

    // Remove successfully synced items
    const remaining = queue.filter(item => !results.includes(item.id));
    await localStorage.set('sync:queue', remaining);
  },
};
```

## Zustand Store Integration

```typescript
// stores/postsStore.ts
import { create } from 'zustand';
import { postRepository } from '@/services/repositories/postRepository';

interface PostsState {
  posts: Post[];
  loading: boolean;
  error: string | null;
  
  fetchPosts: (forceRefresh?: boolean) => Promise<void>;
  createPost: (post: Omit<Post, 'id' | 'created_at' | 'updated_at'>) => Promise<void>;
  syncPending: () => Promise<void>;
}

export const usePostsStore = create<PostsState>((set, get) => ({
  posts: [],
  loading: false,
  error: null,

  fetchPosts: async (forceRefresh = false) => {
    set({ loading: true, error: null });
    try {
      const posts = await postRepository.getPosts(forceRefresh);
      set({ posts, loading: false });
    } catch (error) {
      set({ error: (error as Error).message, loading: false });
    }
  },

  createPost: async (post) => {
    try {
      const newPost = await postRepository.createPost(post);
      set({ posts: [newPost, ...get().posts] });
    } catch (error) {
      set({ error: (error as Error).message });
    }
  },

  syncPending: async () => {
    try {
      await postRepository.syncPendingChanges();
      await get().fetchPosts(true);
    } catch (error) {
      console.error('Sync failed:', error);
    }
  },
}));
```

## Performance Optimization

### Pagination Hook

```typescript
// hooks/usePagination.ts
export function usePagination<T>(
  fetcher: (page: number) => Promise<T[]>,
  pageSize = 20
) {
  const [data, setData] = useState<T[]>([]);
  const [page, setPage] = useState(0);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const loadMore = async () => {
    if (loading || !hasMore) return;

    setLoading(true);
    try {
      const newData = await fetcher(page);
      setData([...data, ...newData]);
      setHasMore(newData.length === pageSize);
      setPage(page + 1);
    } catch (error) {
      console.error('Pagination error:', error);
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, hasMore, loadMore };
}
```

### Optimistic Updates

```typescript
// hooks/useOptimisticUpdate.ts
export function useOptimisticUpdate<T extends { id: string }>(
  items: T[],
  updateFn: (id: string, updates: Partial<T>) => Promise<T>
) {
  const [optimisticItems, setOptimisticItems] = useState(items);

  useEffect(() => {
    setOptimisticItems(items);
  }, [items]);

  const update = async (id: string, updates: Partial<T>) => {
    // Optimistic update
    setOptimisticItems(prev =>
      prev.map(item => (item.id === id ? { ...item, ...updates } : item))
    );

    try {
      // Actual update
      await updateFn(id, updates);
    } catch (error) {
      // Rollback on error
      setOptimisticItems(items);
      throw error;
    }
  };

  return { items: optimisticItems, update };
}
```

## Best Practices Summary

1. **Use UUIDs** for client-generated IDs
2. **Add sync metadata** (created_at, updated_at, synced_at)
3. **Implement soft deletes** (is_deleted flag)
4. **Denormalize strategically** for mobile performance
5. **Use Row Level Security** (RLS) in Supabase
6. **Cache aggressively** with AsyncStorage
7. **Queue offline operations** for later sync
8. **Paginate large datasets**
9. **Use optimistic updates** for better UX
10. **Version your data models** for migrations
