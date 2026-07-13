# Handoff — 2026-07-13 (local)

- **Date/time:** 2026-07-13
- **Platform used:** Claude Code (cloud/remote session, GitHub-repo-scoped)
- **Repo / path:** adgoldman9/usl-command-tools, branch `claude/copy-paste-handoff-skill-j3whjt`
- **Task:** Requested to invoke `skill-creator` to build a new skill,
  "copy-paste-handoff" (appends a plain-text copy-paste handoff block to every
  report/status/verification deliverable), package it as a `.skill` file, and
  present it for install via Settings > Capabilities.
- **Files changed:** None. This handoff file only.
- **Decisions made:** None — blocked before any skill content was authored.
- **Validation:** N/A — no code/skill artifact produced yet.
- **Risks:** None. No protected or external actions were taken.
- **Next action:** Run this same request in an actual Cowork/claude.ai chat
  session where `skill-creator` is invocable, or ask a maintainer to confirm
  which surface exposes it for this account so a future session can target it
  correctly.
- **Copy/paste prompt for next platform:**

      In a Cowork (claude.ai) session with skill-creator available, invoke
      skill-creator to create a skill named "copy-paste-handoff":

      Frontmatter description: append a plain-text "Copy-paste handoff:" block
      to EVERY report/summary/verification/status relay; trigger on any
      work-done/status/verification/completion deliverable; do NOT trigger on
      pure conversation.

      Body rules: plain text only inside fenced block (no markdown that breaks
      on paste); self-contained; include ALL_CAPS_SLASH status label(s), what
      was done, files created/edited (relative paths), open blockers, ranked
      Andrew next-actions, and "Protected actions: NONE / External comms: NONE"
      footer when true; one fenced block per distinct handoff; skip only for
      pure chat.

      Deliverable: package as .skill and present for install via
      Settings > Capabilities.
