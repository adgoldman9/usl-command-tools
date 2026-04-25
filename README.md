# USL Command Tools

This repo is the local code workspace for USL browser tools, dashboards, scripts, and build documentation.

The repo is designed for simple local-first tools that can be opened in a browser, reviewed by Codex, and later moved to GitHub when ready.

## Modules

- `sar-system/` - SAR, ESA, RPPOB, CSI, and quoteability workflow tools.
- `opportunity-tracker/` - SAM.gov, DIBBS, LRAF, NSN, and hardware opportunity tracking.
- `nsn-review-dashboard/` - NSN and NIIN review dashboards and decision-support utilities.
- `supplier-outreach-tools/` - Supplier list cleanup, outreach tracking, and CSV utilities.
- `usl-command-dashboard/` - Daily USL command dashboard, mobile capture, and status reporting.
- `docs/` - Deployment notes, operating docs, and GitHub Pages instructions.

## Local Use

Open each browser tool by opening its `index.html` file directly, unless that tool's README says to use a local server.

## Standards

- Use plain HTML, CSS, and JavaScript unless a framework is explicitly requested.
- Avoid unnecessary dependencies.
- Keep sensitive business data out of public files and repo history.
- Add clear README instructions for each tool.
- Use `AGENTS.md` as the operating guide for Codex work.

## Recommended Next Build Order

1. Build `usl-command-dashboard/`.
2. Build `opportunity-tracker/`.
3. Build `sar-system/`.
4. Add mobile capture and daily status export.
5. Add GitHub Pages deployment docs.
