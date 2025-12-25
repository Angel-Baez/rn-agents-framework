# Conflict Resolution Guidelines

## Overview

When multiple agents work on the same codebase, conflicts can arise. This document provides clear guidelines for resolving conflicts between agents, technical decisions, and implementation approaches.

## Types of Conflicts

### 1. Agent Responsibility Conflicts

**When it happens**: Multiple agents claim ownership of the same task.

**Resolution Process**:
1. Refer to the **Orchestrator** for routing decisions
2. Check agent specializations in the agent catalog
3. The more specialized agent takes priority
4. If equal, defer to the agent who started first

**Example**:
```
Conflict: Both Mobile Architect and Native Modules Engineer want to implement camera integration.

Resolution: 
- Native Modules Engineer handles the Expo Camera setup and permissions
- Mobile Architect designs the UI component that uses the camera
- Clear handoff: Native Modules Engineer provides API, Mobile Architect consumes it
```

### 2. Technical Approach Conflicts

**When it happens**: Agents propose different solutions to the same problem.

**Resolution Process**:
1. **Solution Architect** makes the final decision
2. Each agent presents their approach with pros/cons
3. Solution Architect creates or updates ADR
4. Decision is documented and binding

**Example**:
```
Conflict: State management approach

Mobile Architect suggests: Context API for simple state
Backend Architect suggests: Zustand for consistency with data layer

Resolution (Solution Architect):
- ADR created: Use Zustand for all state management
- Reasoning: Consistency, better DevTools, easier testing
- Context API reserved only for theming
```

### 3. Implementation Conflicts

**When it happens**: Code changes from different agents overlap.

**Resolution Process**:
1. Use Git's conflict resolution tools
2. The agent who made the later change resolves conflicts
3. If complex, involve both agents and Code Reviewer
4. Re-run tests after resolution
5. Request review from affected agents

**Example**:
```
Conflict: Git merge conflict in services/auth.ts

Resolution:
1. Later agent pulls latest changes
2. Resolves conflicts keeping both features
3. Runs tests to ensure nothing broke
4. Tags both agents for review
5. Code Reviewer does final check
```

### 4. Architecture Conflicts

**When it happens**: Proposed changes violate established architectural patterns.

**Resolution Process**:
1. **Solution Architect** reviews the proposal
2. Check against ADRs and framework principles
3. Either approve with explanation or reject with alternative
4. Update ADRs if pattern needs revision

**Example**:
```
Conflict: Developer wants to use Redux instead of Zustand

Resolution (Solution Architect):
- Review ADR 001: State Management with Zustand
- Redux adds complexity (50kb+ bundle size)
- Zustand is sufficient for app needs
- Decision: Stick with Zustand
- If Redux truly needed, create ADR to change standard
```

### 5. Security vs. Feature Conflicts

**When it happens**: A feature request conflicts with security best practices.

**Resolution Process**:
1. **Security Guardian** has veto power on security issues
2. Feature must be redesigned to meet security requirements
3. If impossible, feature is rejected
4. **Product Manager** notified of impact

**Example**:
```
Conflict: Feature requests storing auth token in AsyncStorage

Security Guardian: Tokens must use SecureStore (encrypted)

Resolution:
- Feature must use SecureStore.setItemAsync()
- AsyncStorage only for non-sensitive data
- Security takes priority
- Product Manager informed of implementation change
```

### 6. Performance vs. Feature Conflicts

**When it happens**: A feature negatively impacts performance targets.

**Resolution Process**:
1. **Performance Optimizer** measures impact
2. If target exceeded, feature must be optimized
3. **Mobile Architect** and feature owner collaborate on optimization
4. If optimization impossible, escalate to **Solution Architect**

**Example**:
```
Conflict: New animation increases app startup time by 500ms (target: 2000ms)

Performance Optimizer: Startup increased to 2300ms
Target: Must stay under 2000ms

Resolution:
- Defer animation load until after app renders
- Use lazy loading for animation library
- Measure again: Startup now 1900ms ✓
- Feature approved with optimization
```

### 7. Platform-Specific Conflicts

**When it happens**: Implementation works on one platform but not the other (iOS vs Android).

**Resolution Process**:
1. **Mobile Architect** evaluates platform differences
2. Create platform-specific implementations if needed
3. Ensure consistent UX across platforms
4. Document platform differences

**Example**:
```
Conflict: Date picker looks good on iOS but breaks on Android

Resolution (Mobile Architect):
1. Use Platform.select() for platform-specific components
2. iOS: Use native date picker
3. Android: Use custom modal date picker
4. Ensure both provide same API
5. Test on both platforms
```

## Conflict Resolution Matrix

| Conflict Type | Primary Decision Maker | Can Escalate To | Documentation Required |
|--------------|----------------------|----------------|----------------------|
| Agent Responsibility | Orchestrator | Product Manager | None |
| Technical Approach | Solution Architect | None (final) | ADR |
| Implementation | Code Reviewer | Solution Architect | PR Comments |
| Architecture | Solution Architect | None (final) | ADR Update |
| Security vs Feature | Security Guardian | Solution Architect | Security Review |
| Performance vs Feature | Performance Optimizer | Solution Architect | Performance Report |
| Platform-Specific | Mobile Architect | Solution Architect | Platform Notes |

## Resolution Principles

### 1. Framework Principles Take Priority

Always align with core framework principles:
- Mobile-first architecture
- Performance by default
- Offline-first approach
- Security & privacy
- Developer experience

**Example Decision**:
```
Question: Should we add a large animation library?

Framework Principle: Performance by default
Decision: No, it increases bundle size by 200kb
Alternative: Use React Native Reanimated (already included)
```

### 2. User Experience Over Developer Convenience

When in conflict, prioritize user experience:
- Faster load times
- Smoother animations
- Better accessibility
- Clearer error messages

**Example Decision**:
```
Developer: "Let's use console.log for error messages"
Decision: No, show user-friendly toast messages
Reasoning: Better UX, users shouldn't see console
```

### 3. Security Cannot Be Compromised

Security requirements are non-negotiable:
- Proper authentication
- Secure data storage
- Permission handling
- Input validation

**Example Decision**:
```
Feature: "Skip permission request for faster onboarding"
Security Guardian: "No, permissions are required by OS and privacy laws"
Decision: Keep permissions, improve UX of permission flow
```

### 4. Consistency Over Individual Preference

Follow established patterns:
- Use existing components
- Follow naming conventions
- Match existing architecture
- Keep code style consistent

**Example Decision**:
```
Developer: "I prefer styled-components"
Framework: "We use NativeWind"
Decision: Use NativeWind for consistency
```

### 5. Test Everything

When resolving conflicts:
- Write tests for the solution
- Ensure tests pass on all platforms
- Don't merge without tests

### 6. Document Decisions

All conflict resolutions should be documented:
- ADRs for architecture decisions
- PR comments for implementation decisions
- Updated docs for process decisions

## Escalation Path

```
Level 1: Direct Agent Resolution
  ↓ (if unresolved)
Level 2: Code Reviewer
  ↓ (if unresolved)
Level 3: Solution Architect
  ↓ (if unresolved)
Level 4: Product Manager (for product decisions)
```

## Common Conflict Scenarios

### Scenario 1: Multiple Ways to Handle Offline Data

**Agents Involved**: Offline Architect, Data Engineer, Backend Architect

**Conflict**:
- Offline Architect: Use Realm for complex offline
- Data Engineer: Use AsyncStorage with Supabase sync
- Backend Architect: Use Supabase real-time exclusively

**Resolution Process**:
1. Solution Architect reviews requirements
2. Check data complexity and sync needs
3. Decision based on:
   - Data structure complexity
   - Sync frequency
   - Offline duration
   - Query requirements

**Decision Framework**:
```
Simple data + rare offline → AsyncStorage + Supabase
Complex queries + frequent offline → Realm + Supabase
Real-time critical + online → Supabase real-time
```

### Scenario 2: Component Library Choices

**Agents Involved**: Mobile Architect, Performance Optimizer

**Conflict**:
- Mobile Architect: Use React Native Paper for rich UI
- Performance Optimizer: Custom components for smaller bundle

**Resolution**:
1. Measure bundle size impact
2. Evaluate development time
3. Check customization needs

**Decision Criteria**:
```
If bundle increase < 100kb AND saves > 20 hours development:
  → Use library
Else:
  → Build custom
```

### Scenario 3: Testing Strategy

**Agents Involved**: Test Engineer, QA Lead, Performance Optimizer

**Conflict**:
- Test Engineer: 100% coverage with unit + E2E tests
- QA Lead: Focus on manual testing critical paths
- Performance Optimizer: Tests slow down CI/CD

**Resolution**:
1. Solution Architect defines balanced approach
2. Set coverage targets: 80% unit, critical paths E2E
3. Optimize test performance

**Balanced Approach**:
```
Unit Tests: 80% coverage (fast, run on every commit)
Integration Tests: Critical paths only (run on PR)
E2E Tests: Happy path + critical flows (run nightly)
Manual Testing: New features + regression on release
```

## Conflict Prevention

### 1. Clear Agent Boundaries

Define clear responsibilities:
```
Mobile Architect: UI components, navigation, styling
Native Modules Engineer: Expo modules, permissions, native APIs
Backend Architect: APIs, Supabase, Edge Functions
Data Engineer: Database schema, local storage, sync
```

### 2. Use ADRs Proactively

Create ADRs before conflicts arise:
- Document technical choices early
- Reference ADRs in discussions
- Update ADRs when context changes

### 3. Regular Sync Meetings

For complex features:
- Daily standups for involved agents
- Clear task assignments
- Shared understanding of goals

### 4. Pull Request Templates

Use structured PR templates:
```markdown
## Changes
[Description]

## Agents Involved
@mobile-architect @backend-architect

## Related ADRs
- ADR 003: Image Upload Strategy

## Testing
- [ ] Unit tests pass
- [ ] Tested on iOS
- [ ] Tested on Android
- [ ] Accessibility checked

## Security Review
@security-guardian please review permissions handling
```

## Conflict Documentation Template

```markdown
## Conflict Resolution Record

**Date**: 2024-01-15
**Conflict Type**: Technical Approach
**Agents Involved**: @mobile-architect @performance-optimizer

**Issue**: 
Choice between animation libraries: Lottie vs Reanimated

**Proposed Solutions**:
1. Lottie: Designer-friendly, vector animations
2. Reanimated: Native performance, smaller bundle

**Decision**: Reanimated
**Decision Maker**: Solution Architect
**Reasoning**: 
- Bundle size: Lottie 150kb vs Reanimated (already included)
- Performance: Reanimated runs on UI thread
- Designer can export to JSON, we convert to Reanimated

**Documentation**: Updated ADR 005: Animation Strategy

**Status**: Resolved ✓
```

## Summary

Effective conflict resolution requires:

1. **Clear agent roles** - Know who decides what
2. **Framework alignment** - Follow core principles
3. **Documentation** - Record all decisions
4. **Testing** - Validate resolutions
5. **Communication** - Keep all parties informed
6. **Escalation** - Don't stay stuck, escalate when needed

When conflicts arise:
- Focus on the framework principles
- Prioritize user experience and security
- Document the decision
- Move forward with confidence

The goal is not to avoid conflicts but to resolve them quickly and effectively while maintaining code quality and team productivity.
