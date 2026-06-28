# Claude Mobile → Desktop Sync & Access

How to sync and access **saved memory, chats, files, Cowork sessions, and local
files** between the Claude mobile app and the Claude desktop app.

This is an operating reference, not a USL browser tool. It explains what Claude
already syncs on its own, how to verify it, and how to close the one real gap
(local files) using the Google Drive layer these tools already integrate with.

## The Short Version

| Category | Syncs automatically? | What you do |
| --- | --- | --- |
| Chats / conversations | Yes (server-side) | Sign both apps into the **same Anthropic account** |
| Saved memory | Yes (account-scoped) | Same sign-in; confirm Memory is **on** in both apps |
| Files in chats / Projects | Yes (server-side) | Same sign-in; upload into a **Project**, not a one-off chat |
| Cowork / Claude Code sessions | Yes (cloud-run, account-bound) | Open `claude.ai/code`; **commit work to the repo** |
| Local files (phone / computer) | **No** | Use a **cloud drive as the canonical store** + a Claude connector |

The first four are a sign-in and verification task. Only **local files** require
a real bridge. Build effort should go there.

## 1. Chats, Memory, and Files (already cloud-synced)

Claude conversations, saved memory, and files uploaded into chats or Projects are
stored on Anthropic's servers and tied to your account — not to a single device.
They appear on any app signed into the **same account**.

Recommended setup:

1. Sign in to the **same Anthropic account** on both mobile and desktop. Most
   "my desktop can't see what I did on mobile" problems are two different
   accounts (e.g. Google sign-in on phone vs. email/password on desktop).
2. Confirm **Memory** is enabled in both apps (Settings → Memory / personalization).
   Memory is account-scoped, so once on, saved memory is visible on every device.
3. Put work you want to find later inside a **Project** rather than loose chats.
   Project instructions, Project memory, and Project files all sync with the
   account and are far easier to re-open on the other device.

### Verify it (2 minutes)

- Start a chat on mobile, then open the desktop app — the same chat should appear
  in history within a few seconds of refresh.
- Upload a file into a Project on mobile; open that Project on desktop and confirm
  the file is listed.
- Ask Claude on desktop to recall something you told it on mobile to confirm
  memory is shared.

If any of these fail, it is almost always (a) different accounts, (b) Memory
disabled on one device, or (c) an offline / stale session — sign out and back in.

## 2. Cowork / Claude Code Sessions

Cowork and Claude Code sessions run in **cloud containers**, not on your phone or
laptop. They are reachable from any device at `claude.ai/code` and are bound to
your account, so a session you start on mobile is visible on desktop.

Two things to know:

- The container is **ephemeral**. Anything not committed and pushed is lost when
  the session is reclaimed. The durable, cross-device record of Cowork output is
  **what lands in the Git repo** (for these tools, `usl-command-tools`).
- To "access on desktop" what you did in a mobile Cowork session, open the same
  session from `claude.ai/code`, or just `git pull` the branch the session pushed
  to. The repo is the source of truth, the session is not.

Recommendation: when you drive a Cowork session from mobile, have it **commit and
push** before you end your turn. Then desktop access is just `git pull`.

## 3. Local Files — the only real gap

Claude does **not** sync your device's local filesystem. The desktop app can read
local files (filesystem access, connectors, Claude Code); the mobile app cannot
reach your computer's disk. There is no built-in mobile↔desktop local-file sync.

Close the gap by making a **cloud drive the canonical store** and connecting it to
Claude, so both apps see the same files through Claude itself:

1. Pick one canonical cloud drive: **Google Drive** (already wired into these
   tools via `apps-script/google-sheets-sync/`), or iCloud Drive / Dropbox /
   OneDrive if you prefer.
2. Keep working files **in the drive**, not in a phone-only or desktop-only
   folder. Treat the local copies as caches of the drive.
3. Connect that drive to Claude (Settings → Connectors / the Google Drive
   connector). Once connected at the account level, **both** mobile and desktop
   Claude can search and read the same Drive files — that is the actual sync.
4. On desktop only, if you need Claude to edit files in place, point Claude Code /
   the filesystem connector at a folder that is itself **synced by the drive's
   desktop client** (e.g. Google Drive for Desktop). Edits then propagate to the
   cloud and become visible to mobile.

### Recommended canonical folder layout

```text
USL Command Drive/           (Google Drive root — the source of truth)
  captures/                  CSV exports from Mobile Capture Inbox
  trackers/                  Opportunity / SAR / dashboard exports
  files/                     Working docs, drawings, references
  claude/                    Anything you hand to Claude as a Project file
```

Point a Claude **Project** at `claude/` (upload or connect it), keep field
captures flowing into `captures/` via the existing CSV / Sheets bridge, and both
Claude apps plus these USL tools all read from one place.

## Putting It Together for USL

The cleanest cross-device setup that uses what this repo already has:

1. **Account:** same Anthropic account on mobile + desktop → chats, memory, and
   Project files sync for free.
2. **Cowork:** drive sessions from `claude.ai/code`; require commit + push so
   desktop access is `git pull`.
3. **Local files:** Google Drive is the canonical store; connect the Google Drive
   connector to Claude so both apps read the same files; use Google Drive for
   Desktop if you need in-place desktop edits.
4. **Field data:** keep using **Mobile Capture Inbox** → CSV / Google Sheets sync
   (`docs/google-sheets-sync.md`) so structured captures reach desktop as data,
   not just as files.

## Security Notes

- Do not commit private USL records, supplier data, pricing, CAGE/UEI, or
  credentials to GitHub. The repo hosts tool interfaces and docs only.
- Treat any deployed Apps Script / connector URL as sensitive if it grants data
  access.
- A Claude connector reads whatever you point it at — scope the connected Drive
  folder to what Claude should actually see, not your entire Drive.

## What This Does Not Do

- There is no public API to export Claude's saved memory or Cowork session state
  to an external store; sync of those is handled by Anthropic's account, not by
  these tools.
- This is an account + cloud-drive architecture, not a custom sync engine. The
  only thing this repo contributes is the canonical Google Drive layer and the
  CSV / Sheets bridge for structured field data.
