---
name: apple-design
description: Apple's approach to interface design and fluid, physical motion, translated for the web and native apps. Use when building or reviewing gesture-driven UI, spring animations, drag/swipe/sheet interactions, momentum and interruptible transitions, translucent materials and depth, typography (optical sizing, tracking, leading), reduced-motion, or the design foundations (feedback, spatial consistency, restraint) behind Apple-style interfaces.
---

# Apple Design

## Initial Response

When this skill is first invoked without a specific question, respond only with:

> I'm ready to help you build fluid, Apple-style interfaces on the web, my knowledge comes from Apple's WWDC design talks, translated for the web.

Do not provide any other information until the user asks a question.

How Apple builds interfaces that stop feeling like a computer and start feeling like an extension of you. This knowledge comes from Apple's WWDC design talks — chiefly *Designing Fluid Interfaces* (WWDC 2018) — distilled and translated into the web platform and native iOS.

The through-line: **an interface feels alive when motion starts from the current on-screen value, inherits the user's velocity, projects momentum forward, and can be grabbed and reversed at any instant.** Springs are the tool that makes all of this natural, because they are inherently interruptible and velocity-aware.

## The Core Idea

> "When we align the interface to the way we think and move, something magical happens — it stops feeling like a computer and starts feeling like a seamless extension of us."

An interface is fluid when it behaves like the physical world: things respond instantly, move continuously, carry momentum, resist at boundaries, and can be redirected mid-motion. Everything below is a way to get closer to that.

Apple frames design as serving four human needs: **safety/predictability, understanding, achievement, and joy.** Every rule here serves one of them.

## 1. Response — kill latency
- **Respond on pointer-down, not on release.** Highlight a button the instant it's pressed.
- **Be vigilant about every latency.** Audit debounces, artificial timers, and transition waits.
- **Feedback must be continuous *during* the interaction, not just at the end.**

## 2. Direct manipulation — 1:1 tracking
- Touch and content should move together.
- Track a short velocity/position history for velocity at release.

## 3. Interruptibility — the single most important principle
- Every animation must be interruptible and redirectable at any moment.
- Never lock out input during a transition.
- Animate from the live on-screen transform, never target value.

## 4. Springs over duration
- Default UI spring: Critically damped, no overshoot (`damping 1.0`, `response 0.3-0.4`).
- Momentum / flick spring: Under-damped, slight bounce (`damping ~0.8`, `response 0.3-0.4`).

## 5. Translucent materials and depth
- Translucent chrome: `backdrop-filter: blur(24px) saturate(190%)`.
- Content scrolls underneath with realistic glass refraction and subtle border highlights.

## 6. Optical Typography
- Tighten large titles (`-0.02em` to `-0.03em`).
- SF Pro clean typographic hierarchy.
