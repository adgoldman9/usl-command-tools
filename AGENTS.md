# USL Codex Operating Instructions

## Company Context

USL is building aerospace, defense, maritime, and weapons-system hardware workflows focused on government contracting, defense logistics, supplier development, SAR/ESA workflows, NSN-driven opportunity review, and future AI/CAD infrastructure.

Primary business lanes:
- SAM.gov, DIBBS, LRAF, and NSN opportunity review
- SAR / ESA / RPPOB package support
- Supplier and manufacturer outreach
- SBIR / AFWERX proposal support
- USL internal software tools
- CAD / scan-to-model / bad-drawing-to-3D-model infrastructure

## Codex Role

Codex is responsible only for code, scripts, dashboards, HTML tools, repo structure, local file utilities, and documentation related to software builds.

Do not make business decisions. Instead, create tools that support the ChatGPT business workflow.

## Project Standards

Use simple, maintainable code.
Prefer plain HTML, CSS, and JavaScript unless a framework is explicitly requested.
Keep tools mobile-friendly and desktop-friendly.
Use clear file names.
Add README instructions for every tool.
Avoid unnecessary dependencies.
Do not expose private USL business data in public-facing files.
Do not hard-code sensitive information, API keys, passwords, CAGE codes, UEI, private emails, or supplier pricing.

## Required Output Standards

For every build task:
1. Summarize what changed.
2. List files created or modified.
3. Explain how to run or open the tool.
4. Identify remaining issues or limitations.
5. Provide a short handoff note for ChatGPT review.

## Testing

For browser tools:
- Confirm the HTML opens locally.
- Confirm mobile layout is usable.
- Confirm forms can add/edit/delete records when applicable.
- Confirm CSV or JSON export works when applicable.

For scripts:
- Include usage instructions.
- Include sample input/output where practical.
- Do not delete user data unless explicitly instructed.

## USL Design Preferences

Professional, clean, defense-business aesthetic.
Use concise labels.
Prioritize workflow speed over visual complexity.
Mobile usability matters because USL uses mobile throughout the day.
Desktop usability matters for deeper review and file work.

## Data Categories

Common USL fields:
- Opportunity ID
- Notice ID
- Solicitation number
- NSN
- NIIN
- FSC
- Part name
- Agency
- Buyer / Contracting Officer
- Due date
- AMC / AMSC
- CSI status
- TDP / cFolders status
- NSNLookup status
- ESA status
- SAR status
- Supplier status
- Decision: Pursue / Hold / Skip / Parked
- Next action
- Follow-up date
- Notes

## Handoff Rule

When a task is complete, create a clear summary that can be pasted back into ChatGPT under:

CODEX HANDOFF SUMMARY
- Task completed:
- Files changed:
- How to test:
- Remaining issues:
- Recommended next action:
