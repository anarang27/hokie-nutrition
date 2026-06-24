---
name: Hokie Nutrition
colors:
  surface: '#fff8f7'
  surface-dim: '#e9d5d7'
  surface-bright: '#fff8f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff0f1'
  surface-container: '#fee9eb'
  surface-container-high: '#f8e3e5'
  surface-container-highest: '#f2dee0'
  on-surface: '#24191b'
  on-surface-variant: '#564145'
  inverse-surface: '#3a2d2f'
  inverse-on-surface: '#ffecee'
  outline: '#897175'
  outline-variant: '#dcbfc3'
  surface-tint: '#a63455'
  primary: '#6c012b'
  on-primary: '#ffffff'
  primary-container: '#8b1f41'
  on-primary-container: '#ff9eb2'
  inverse-primary: '#ffb1c0'
  secondary: '#994700'
  on-secondary: '#ffffff'
  secondary-container: '#ff8934'
  on-secondary-container: '#662d00'
  tertiary: '#243449'
  on-tertiary: '#ffffff'
  tertiary-container: '#3b4b60'
  on-tertiary-container: '#aabbd4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9df'
  primary-fixed-dim: '#ffb1c0'
  on-primary-fixed: '#3f0016'
  on-primary-fixed-variant: '#861b3e'
  secondary-fixed: '#ffdbc8'
  secondary-fixed-dim: '#ffb68b'
  on-secondary-fixed: '#321300'
  on-secondary-fixed-variant: '#743400'
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
  background: '#fff8f7'
  on-background: '#24191b'
  surface-variant: '#f2dee0'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 41px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 16px
  gutter: 12px
---

## Brand & Style
The design system for this application is built for the active Virginia Tech student. It balances the proud, collegiate heritage of the university with the high-energy, data-driven aesthetics of modern fitness platforms. The personality is energetic, disciplined, and accessible.

The design style is **Corporate Modern with a Fitness Edge**. It utilizes clean white spaces, significant margin breathability, and large touch targets optimized for one-handed mobile use. Depth is achieved through soft, ambient shadows and subtle Burnt Orange gradients that signal momentum and progress. The interface avoids clutter, focusing on clear data visualization and macro-tracking performance.

## Colors
The palette is anchored by the university's core identity. **Chicago Maroon** is used for primary actions, navigation headers, and brand moments. **Burnt Orange** serves as the accent for motivation, progress indicators, and "active" states. 

**Slate (#0F172A)** provides a high-contrast foundation for typography to ensure outdoor legibility. The background remains a crisp **White**, while **Slate-50 (#F8FAFC)** is used for card surfaces to create a subtle separation from the base canvas. Success, warning, and error states should use accessible variants of emerald, amber, and rose to complement the primary maroon.

## Typography
This design system utilizes **Inter** to emulate the crisp, functional feel of SF Pro while maintaining a distinct, systematic look. 

The scale follows a rhythmic iOS-centric approach. **Display** and **Headline** roles use tighter letter spacing and bold weights to create a sense of strength. **Body** text is optimized for readability with a 1.4x-1.5x line height. **Labels** are used for macro-nutrients and secondary metadata, often utilizing semi-bold weights to ensure they remain legible even at small sizes.

## Layout & Spacing
The layout follows a **Fluid Grid** model designed specifically for mobile viewports. The standard horizontal margin is **16px**, ensuring content doesn't feel cramped against the screen edges. 

The spacing system is built on a **4px baseline grid**. Components like cards and list items are separated by **12px or 16px** (md) to maintain a clean, airy feel. Large sections, such as the transition between a calorie summary and a meal list, should use **32px** (xl) vertical spacing.

## Elevation & Depth
Depth is created using **Ambient Shadows** and **Tonal Layering**. 

1.  **Level 0 (Canvas):** Pure white background.
2.  **Level 1 (Cards):** These use a very soft, diffused shadow (Offset: 0, 4; Blur: 20; Opacity: 4% Black) to lift them off the canvas. 
3.  **Level 2 (Active/Floating):** Primary action buttons or active meal cards use a slightly more pronounced shadow with a hint of the brand color (Offset: 0, 8; Blur: 24; Opacity: 10% Maroon) to signify interactability.

Gradients should be used sparingly on progress rings or "Goal Reached" states, moving from **Burnt Orange** to a lighter tint to imply energy.

## Shapes
The shape language is defined by generous, friendly curves. The standard radius for cards and main containers is **16px** (rounded-lg). Small elements like buttons and input fields follow this **16px** radius to maintain a consistent "squircle" feel throughout the interface. 

Progress bars and macro-chips use a fully **Pill-shaped** radius (999px) to provide a visual contrast against the more structured rectangular cards.

## Components

### Buttons
*   **Primary:** Solid Chicago Maroon with white text. High-profile 16px corner radius. Minimum height of 54px for accessibility.
*   **Secondary:** White background with a Burnt Orange border and text.
*   **Ghost:** Transparent background with Slate text, used for "Cancel" or "Edit" actions.

### Macro-Nutrition Chips
Small, pill-shaped indicators. Each macro (Protein, Carbs, Fat) should have a consistent color-coding (e.g., Maroon for Protein, Orange for Carbs, Slate for Fat) with a subtle light-tint background and dark text.

### Progress Indicators
Circular rings for daily calorie goals. Use a thick 8-12pt stroke with a rounded cap. The "unfilled" track should be a very light Slate-100, while the "filled" track uses a Burnt Orange gradient.

### Input Fields
Large, accessible fields with a 16px radius and a light grey border. Upon focus, the border transitions to Chicago Maroon with a subtle outer glow.

### Lists & Cards
Meal items are displayed in white cards with 16px padding. Use horizontal dividers between list items within a card that are only 1px thick and colored in Slate-100.