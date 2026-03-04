# Design System: "Luminous Mote"

A terminal-inspired dark theme with glowing blue accents, designed to feel cohesive with Owloops CLI tools while maintaining a modern aesthetic.

## Design Inspirations

### App / Dashboard

| Source | What We Borrowed |
|--------|------------------|
| [Oxide Console](https://console-preview.oxide.computer) | Dark theme, status badges with borders, data-dense tables, uppercase headers |
| [ASCIIMoon](https://asciimoon.com) | Terminal aesthetic, single accent color philosophy, pure black backgrounds |
| [WebTUI](https://webtui.ironclad.sh) | Tab styling, field type indicators, bordered panels, vim-style status elements |
| [Terminal Trove](https://terminaltrove.com) | Button glow effects, uppercase labels, green accents on dark |
| [Owloops](https://owloops.com) | Card hover effects, monospace for technical content, terminal mockups |
| [OpenCode](https://opencode.ai) | Clean code blocks, minimalist terminal vibes |

### Landing Page / Marketing

| Source | What We Borrowed |
|--------|------------------|
| [Railway](https://railway.com) | Full-viewport atmospheric illustration in hero, warm mountain/sky tones over dark theme, product UI floating with perspective tilt, generous whitespace between feature sections |
| [Writizzy](https://writizzy.com) | AI-generated warm illustration as hero background (cozy room at sunset), rich purple/amber gradient palette, frosted glass UI frames, editorial feel |
| [Linear](https://linear.app) | Enormous bold headings, maximum breathing room, perspective product screenshots as centerpiece, clean section rhythm |

The landing page blends atmospheric warmth (Railway/Writizzy) with the dark terminal precision (Oxide/OpenCode) from the app. Warm and inviting, not cold and sterile, while staying true to the developer-tool identity.

---

## Color Palette

### Backgrounds

```css
--color-bg-deep: #0a0e14;        /* Main page background - nearly black with blue undertone */
--color-bg-surface: #111827;     /* Cards, header, modals - elevated surface */
--color-bg-elevated: #1a2332;    /* Hover states, modal footer, table headers */
```

### Borders

```css
--color-border: #1e293b;         /* Default borders */
--color-border-subtle: #283548;  /* Hover state borders */
```

### Text

```css
--color-text-primary: #e2e8f0;   /* Main text - bright but not pure white */
--color-text-secondary: #94a3b8; /* Secondary text, descriptions */
--color-text-muted: #64748b;     /* Placeholders, hints, disabled */
```

### Accent Colors (Blue)

```css
--color-accent: #3b82f6;         /* Primary accent - buttons, active states */
--color-accent-glow: #60a5fa;    /* Hover states, highlights, links */
--color-accent-dim: #1e40af;     /* Badge borders, subtle accents */
--color-accent-bg: rgba(59, 130, 246, 0.1);       /* Accent backgrounds */
--color-accent-bg-hover: rgba(59, 130, 246, 0.15); /* Accent hover backgrounds */
```

### Semantic Colors

```css
/* Success - Green */
--color-success: #22c55e;
--color-success-bg: rgba(34, 197, 94, 0.15);

/* Warning - Amber */
--color-warning: #f59e0b;
--color-warning-bg: rgba(245, 158, 11, 0.15);

/* Error - Red */
--color-error: #ef4444;
--color-error-bg: rgba(239, 68, 68, 0.15);

/* Info - Blue (same as accent) */
--color-info: #3b82f6;
--color-info-bg: rgba(59, 130, 246, 0.15);
```

---

## Typography

### Font Families

```css
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', Consolas, monospace;
```

### Usage Guidelines

- **Inter (Sans)**: UI elements, headings, body text, buttons, labels
- **JetBrains Mono**: IDs, field names, code, technical values, timestamps, email addresses

### Font Sizes

```css
html { font-size: 14px; }  /* Base size */

h1 { font-size: 2rem; }      /* 28px */
h2 { font-size: 1.5rem; }    /* 21px */
h3 { font-size: 1.25rem; }   /* 17.5px */
h4 { font-size: 1.125rem; }  /* 15.75px */

/* Body text: 0.875rem - 0.9375rem (12.25px - 13.125px) */
/* Small text: 0.75rem - 0.8125rem (10.5px - 11.375px) */
/* Labels/badges: 0.6875rem (9.625px) */
```

### Text Treatments

- **Uppercase + letter-spacing**: Table headers, section titles, badges, labels
- **Font-weight 600-700**: Headings, stat values, important text
- **Font-weight 500**: Labels, field names, buttons

---

## Spacing

```css
--spacing-xs: 0.25rem;   /* 3.5px - tight spacing */
--spacing-sm: 0.5rem;    /* 7px - element gaps */
--spacing-md: 1rem;      /* 14px - section spacing */
--spacing-lg: 1.5rem;    /* 21px - card padding */
--spacing-xl: 2rem;      /* 28px - page sections */
```

---

## Border Radius

```css
--radius-sm: 4px;   /* Badges, small elements */
--radius-md: 6px;   /* Buttons, inputs, field items */
--radius-lg: 8px;   /* Cards, modals, sections */
```

---

## Shadows & Effects

### Shadows

```css
--shadow-glow: 0 0 20px rgba(59, 130, 246, 0.15);           /* Blue glow on hover */
--shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.3),
               0 2px 4px -2px rgba(0, 0, 0, 0.2);           /* Subtle card shadow */
--shadow-modal: 0 25px 50px -12px rgba(0, 0, 0, 0.5);       /* Modal drop shadow */
```

### Transitions

```css
--transition-fast: 0.15s ease;    /* Hovers, color changes */
--transition-normal: 0.2s ease;   /* Larger animations */
```

### Glow Effect Pattern

Cards and buttons get a blue glow on hover:

```css
.element:hover {
    border-color: var(--color-accent);
    box-shadow: var(--shadow-glow);
}
```

---

## Component Patterns

### Buttons

**Primary (Default)**

- Background: `--color-accent`
- Text: `--color-text-primary`
- Hover: `--color-accent-glow` + glow shadow

**Outline**

- Background: transparent
- Border: `--color-border`
- Hover: border becomes accent, background becomes accent-bg

**Secondary**

- Background: `--color-bg-elevated`
- Border: `--color-border`

**Contrast (Danger)**

- Background: `--color-error`
- Hover: darker red + red glow

### Badges

```css
.badge {
    padding: 0.25rem 0.625rem;
    border-radius: var(--radius-sm);
    font-size: 0.6875rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    background: var(--color-accent-bg);
    color: var(--color-accent-glow);
    border: 1px solid var(--color-accent-dim);
}
```

### Status Indicators

Like Oxide Console - pill-shaped with colored borders:

- Success (2xx): Green text + green-tinted background + green border
- Redirect (3xx): Blue text + blue-tinted background
- Client Error (4xx): Amber/warning colors
- Server Error (5xx): Red/error colors

### Cards

- Background: `--color-bg-surface`
- Border: `--color-border`
- Hover: border lightens, optional glow effect
- Transform: `translateY(-2px)` on hover for lift effect

### Tables

- Header background: `--color-bg-elevated`
- Header text: uppercase, muted color, small font
- Row hover: `--color-bg-elevated`
- Selected row: `--color-accent-bg`

### Modals

- Backdrop: `rgba(0, 0, 0, 0.7)` with `backdrop-filter: blur(4px)`
- Content: `--color-bg-surface` with border
- Footer: `--color-bg-elevated` for visual separation

### Form Inputs

- Background: `--color-bg-surface`
- Border: `--color-border`
- Focus: accent border + `box-shadow: 0 0 0 3px var(--color-accent-bg)`
- Placeholder: `--color-text-muted`

---

## Design Principles

1. **Terminal DNA**: Embrace monospace fonts, uppercase labels, and dark backgrounds that evoke CLI tools

2. **Single Accent Philosophy**: Blue is the primary accent. Use it consistently for interactive elements, active states, and highlights

3. **Subtle Luminosity**: Use glow effects sparingly on hover to add depth without overwhelming

4. **Information Density**: Pack useful information into views without feeling cluttered. Use whitespace strategically

5. **Consistent Visual Language**: Every component uses the same CSS variables. This makes theming trivial and ensures visual coherence

6. **Accessibility**: Maintain sufficient contrast ratios. The light text on dark backgrounds provides good readability

---

## Reference Colors

```
#000080  - Navy (deep accent)
#1e3a8a  - Dark Blue (halo)
#3b82f6  - Blue (body) → --color-accent
#60a5fa  - Light Blue (highlight) → --color-accent-glow
```
