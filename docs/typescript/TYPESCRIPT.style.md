# TypeScript Style Guide

Based on [Google's TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html), adapted for the BrowserBird project.

**Runtime constraint:** This project uses `erasableSyntaxOnly: true` for native TypeScript execution on Node.js 22.21+. Only syntax that can be erased (stripped) is allowed — no enums, namespaces, parameter properties, or decorators.

## Table of Contents

- [Source File Basics](#source-file-basics)
- [Source File Structure](#source-file-structure)
- [Imports and Exports](#imports-and-exports)
- [Language Features](#language-features)
- [Type System](#type-system)
- [Naming](#naming)
- [Comments Policy](#comments-policy)
- [References](#references)

## Source File Basics

### File Encoding

Source files are encoded in UTF-8.

### Whitespace

Use ASCII horizontal space (0x20) only. All other whitespace in string literals must be escaped.

### Special Escape Sequences

Use special escape sequences (`\'`, `\"`, `\\`, `\n`, `\r`, `\t`) rather than numeric escapes.

## Source File Structure

Files consist of the following, in order:

1. `import type` statements
2. `import` statements
3. The file's implementation

Separate each section with exactly one blank line.

## Imports and Exports

### Import Types

| Type | Example | Use For |
|------|---------|---------|
| Named | `import { SomeThing } from './foo.ts'` | Most imports |
| Type-only | `import type { SomeType } from './types.ts'` | Types, interfaces (required by `verbatimModuleSyntax`) |
| Module | `import * as foo from './foo.ts'` | Large APIs with many symbols |
| Default | `import SomeThing from 'external-lib'` | Only for external code requiring them |
| Side-effect | `import './setup.ts'` | Libraries with side effects on load |

### Import Paths

- Always include `.ts` extension in relative imports (`./foo.ts`, not `./foo`)
- Use relative imports within the same project
- Limit parent steps (`../../../` — consider restructuring if needed)
- Prefer named imports for frequently used symbols
- Use `import type` for all type-only imports (enforced by `verbatimModuleSyntax`)

```typescript
import type { SessionConfig, AgentConfig } from './types.ts';
import { createSession } from './session.ts';
```

### Exports

Use named exports exclusively:

```typescript
export class Foo { }
export function bar() { }
export const SOME_CONSTANT = 42;
```

Do not use default exports:

```typescript
export default class Foo { }  // WRONG
```

### Export Visibility

Only export symbols used outside the module. Minimize exported API surface.

## Language Features

### Variable Declarations

Always use `const` or `let`. Never use `var`.

```typescript
const foo = otherValue;
let bar = someValue;
```

### Banned Syntax (erasableSyntaxOnly)

The following TypeScript features emit JavaScript that Node's type-stripping cannot handle. Do not use them:

- **`enum`** — use literal union types or `as const` objects instead
- **Parameter properties** (`constructor(private x: T)`) — assign manually in the constructor body
- **`namespace`** — use ES modules
- **Decorators** (`@decorator`) — not compatible with type-stripping

### Array Literals

Do not use the Array constructor:

```typescript
const a = [2];
const b = [2, 3];
const c = Array.from<number>({ length: 5 }).fill(0);
```

### Object Literals

Do not use the Object constructor. Use object literal syntax:

```typescript
const obj = { a: 0, b: 1, c: 2 };
```

### Classes

Assign properties manually in the constructor body (parameter properties are banned):

```typescript
class SessionRouter {
  private readonly db: Database;
  private readonly config: SessionConfig;

  constructor(db: Database, config: SessionConfig) {
    this.db = db;
    this.config = config;
  }
}
```

### Visibility

- Limit symbol visibility as much as possible
- Use `readonly` for properties that shouldn't change
- Never use `public` modifier — it is the default

### Functions

Prefer function declarations for named functions:

```typescript
function createSession(channelId: string): Session {
  return { channelId, createdAt: new Date() };
}
```

Use arrow functions for callbacks:

```typescript
messages.filter((msg) => msg.threadTs === parentTs);
```

### Control Structures

Always use braced blocks:

```typescript
for (let i = 0; i < x; i++) {
  doSomethingWith(i);
}

if (x) {
  doSomething();
}
```

### Equality Checks

Always use triple equals:

```typescript
if (foo === 'bar' || baz !== bam) {
  // ...
}
```

Exception: Use `== null` to check for both null and undefined.

### Exception Handling

Always use `new Error()`. Only throw Error objects, never primitives:

```typescript
throw new Error('Something went wrong');

new Promise((resolve, reject) => void reject(new Error('message')));
```

### Error Suppression

Never use `@ts-ignore`. Use `@ts-expect-error` with a documented reason:

```typescript
// @ts-expect-error — node:sqlite types lag behind runtime API
const db = new DatabaseSync(':memory:');
```

`@ts-expect-error` will fail if the suppressed error is fixed, preventing stale suppressions.

## Type System

### Type Inference

Rely on type inference for trivially inferred types:

```typescript
const x = 15;
const y = new Set<string>();
```

### Undefined and Null

- Use `undefined` or `null` appropriately based on API conventions
- Prefer optional (`?:`) over `| undefined`
- Do not include `| null` or `| undefined` in type aliases

```typescript
// Bad
type CoffeeResponse = Latte | Americano | undefined;

// Good
type CoffeeResponse = Latte | Americano;
function getCoffee(): CoffeeResponse | undefined { ... }
```

### Prefer Interfaces Over Type Aliases

Use interfaces for object shapes. Use type aliases for unions, intersections, and primitives:

```typescript
// Interface for object shapes
interface SessionRecord {
  channelId: string;
  threadTs: string;
  claudeSessionId: string;
  lastActive: string;
}

// Type alias for unions
type MessageDirection = 'in' | 'out';
```

### Enums Replacement

Since `enum` is banned, use literal union types for simple cases and `as const` objects when you need runtime values:

```typescript
// Simple: literal union
type SessionStatus = 'active' | 'stale' | 'closed';

// When you need runtime iteration or lookup:
const SESSION_STATUS = {
  ACTIVE: 'active',
  STALE: 'stale',
  CLOSED: 'closed',
} as const;
type SessionStatus = (typeof SESSION_STATUS)[keyof typeof SESSION_STATUS];
```

### Discriminated Unions

Use discriminated unions to model states. Each variant carries exactly the data it needs — no optional property soup:

```typescript
interface LoadingState {
  status: 'loading';
}

interface ErrorState {
  status: 'error';
  error: Error;
}

interface SuccessState {
  status: 'success';
  data: string;
  sessionId: string;
}

type ClaudeResponse = LoadingState | ErrorState | SuccessState;

function handleResponse(response: ClaudeResponse) {
  switch (response.status) {
    case 'loading':
      showTypingIndicator();
      break;
    case 'error':
      postErrorMessage(response.error);
      break;
    case 'success':
      postToSlack(response.data);
      break;
  }
}
```

### Const Assertions and Immutability

Use `as const` for immutable literal values. Use `Readonly<T>` and `readonly` to prevent mutation:

```typescript
const SUPPORTED_EVENTS = ['message', 'app_mention', 'reaction_added'] as const;
type SupportedEvent = (typeof SUPPORTED_EVENTS)[number];

function processConfig(config: Readonly<AgentConfig>) {
  // config properties cannot be mutated
}
```

### Utility Types

Use built-in utility types to derive types from existing ones — avoid duplicating interface shapes:

```typescript
// Pick fields for a specific operation
type SessionUpdate = Pick<SessionRecord, 'lastActive' | 'messageCount'>;

// Make all fields optional for partial updates
type PartialConfig = Partial<AgentConfig>;

// Omit internal fields for public API
type PublicSession = Omit<SessionRecord, 'claudeSessionId'>;

// Require specific optional fields
type ValidatedConfig = Required<Pick<Config, 'slack' | 'agents'>>;

// Key-value mapping
type AgentMap = Record<string, AgentConfig>;
```

### Array Types

For simple types, use syntax sugar:

```typescript
let a: string[];
let b: readonly string[];
let c: string[][];
```

For complex types, use `Array<T>`:

```typescript
let e: Array<{ n: number; s: string }>;
let f: Array<string | number>;
```

### Avoid `any`

Instead of `any`:

- Provide a more specific type
- Use `unknown` (requires type narrowing before use, unlike `any`)
- If necessary, suppress with `@ts-expect-error` and document why

## Naming

### Identifier Styles

| Style | Category |
|-------|----------|
| UpperCamelCase | class, interface, type, type parameters |
| lowerCamelCase | variable, parameter, function, method, property, module alias |
| CONSTANT_CASE | global constant values, `as const` object keys |

### Descriptive Names

Use descriptive and clear names:

```typescript
errorCount
dnsConnectionIndex
referrerUrl
customerId
```

Avoid abbreviations:

```typescript
n           // bad
nErr        // bad
nCompConns  // bad
```

### Camel Case for Acronyms

Treat abbreviations as whole words:

```typescript
loadHttpUrl
XmlHttpRequest
```

### No Prefix/Suffix Underscores

Do not use `_` as prefix or suffix for identifiers.

Exception: unused callback parameters may use `_` prefix to satisfy the linter:

```typescript
array.map((_item, index) => index);
```

## Comments Policy

**Avoid scattered single-line comments throughout code.**

### JSDoc

Use `/** JSDoc */` for documentation that users should read:

```typescript
/**
 * Computes weight based on three factors:
 *
 * - items sent
 * - items received
 * - last timestamp
 */
function computeWeight() { }
```

### Implementation Comments

Use `//` sparingly for implementation notes that only concern the code itself.

### What NOT to Do

```typescript
const x = 5;               // set x to 5
const user = getUser();     // get the user
arr.push(item);             // add item to array
```

### What TO Do

Write self-documenting code:

```typescript
const maxRetryAttempts = 5;
const currentUser = await userService.findById(userId);
pendingNotifications.push(notification);
```

Use JSDoc for complex or public APIs:

```typescript
/**
 * Spawns a Claude CLI subprocess with streaming output.
 * Returns an async iterator of stream-json events.
 */
function spawnClaude(message: string, sessionId?: string): AsyncIterable<StreamEvent> {
  // ...
}
```

## References

- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
