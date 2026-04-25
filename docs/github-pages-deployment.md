# GitHub Pages Deployment

Use this document after the private GitHub repo exists and the local files are pushed.

## Recommended Repo

Create one private repo:

`adgoldman9/usl-command-tools`

Use the repo for tool interfaces, scripts, dashboards, README files, and sample/demo data only.

Do not put sensitive USL data, supplier pricing, private contact lists, proposal content, credentials, CAGE codes, UEI, API keys, or private emails into GitHub Pages.

## Required Entry Files

GitHub Pages needs an entry file in the published source folder.

This repo uses:

- `index.html` at the repo root as the launch page.
- `index.html` inside each tool folder.
- `.nojekyll` at the repo root.

## Enable Pages

1. Open the GitHub repo.
2. Go to `Settings`.
3. Open `Pages`.
4. Set `Source` to `Deploy from a branch`.
5. Set `Branch` to `main`.
6. Set folder to `/root`.
7. Save.

The launch URL should be:

`https://adgoldman9.github.io/usl-command-tools/`

GitHub Pages deployment can take several minutes after pushing changes.

## Test URLs

- `https://adgoldman9.github.io/usl-command-tools/`
- `https://adgoldman9.github.io/usl-command-tools/usl-command-dashboard/`
- `https://adgoldman9.github.io/usl-command-tools/opportunity-tracker/`
- `https://adgoldman9.github.io/usl-command-tools/sar-system/`
- `https://adgoldman9.github.io/usl-command-tools/nsn-review-dashboard/`
- `https://adgoldman9.github.io/usl-command-tools/supplier-outreach-tools/`

## Common 404 Causes

- GitHub Pages is not enabled.
- Wrong branch selected.
- Wrong folder selected.
- Missing `index.html`.
- File named `Index.html` instead of `index.html`.
- Folder name mismatch.
- Repo name mismatch.
- Deployment is still running.

## Public Vs Private

Use private repo visibility while building.

Only publish interfaces and sample/demo data. Keep real USL working data in Google Drive, ChatGPT Project files, local folders, or private spreadsheets.
