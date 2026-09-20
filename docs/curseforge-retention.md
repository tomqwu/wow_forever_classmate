# CurseForge file retention

The user requested on 2026-09-20 that publishing a new version remove old
versions from CurseForge project **1700438**. Keep only the newest approved
version publicly available. GitHub releases and their upload receipts remain.

## Current automation limit

As checked on 2026-09-20, the official
[Upload API](https://support.curseforge.com/support/solutions/articles/9000197321)
documents upload and metadata update operations, but no archive/delete operation
for the `CURSE_FORGE` upload token. Do not invent endpoints, send undocumented
status fields, or treat a successful upload as cleanup confirmation.

The shared publisher used by automatic releases, manual workflow dispatch, and
local runs emits a cleanup notice after uploading or finding an existing valid
receipt. GitHub Actions shows a warning and a job summary saying that cleanup
is pending. Dry runs do not request cleanup. Publishing is serialized across
project 1700438. A successful CI run confirms publishing, not old-file removal.

## Complete each publication

1. Verify the GitHub ZIP hash and CurseForge upload receipt as usual.
2. In the CurseForge author dashboard, open project 1700438 and its Files tab.
   Confirm the newest version is approved and downloadable; upload acceptance
   alone is insufficient. If it is pending or rejected, keep the latest approved
   version available.
3. Archive older versions, leaving the newest approved version public. Determine
   the newest version from the version numbers, not the most recently rerun job.
4. Check the public Files listing and record which file IDs were archived.
   Until that verification, report cleanup as pending.

[CurseForge's file-management documentation](https://support.curseforge.com/support/solutions/articles/9000197242)
explains that archiving removes files from public view and standalone downloads
while allowing restoration. Permanent deletion requires archiving first and is
not needed for this public-retention policy.

Automatic removal remains unimplemented until a supported authenticated
file-management operation is available. Dashboard access is required to finish
cleanup today; no browser session credentials belong in the repository or logs.
