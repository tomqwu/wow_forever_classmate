# Mail recipients: alts and recents

Classmate 0.30.0 adds a compact side panel to the native **Send Mail** tab. It
shows both **Alts** and **Recent recipients**, with five rows and independent
pagination for each list. Click a name to fill the recipient field; right-click
to forget its saved record. Full names and realm suffixes are available on hover.

## Discovery and persistence

- Log into each character once with Classmate and its mail feature enabled.
  The addon records that observed character; it cannot enumerate the account's
  unplayed roster. The current character is excluded from its own alt list.
- Alts are filtered to the current realm and faction. Readable realm IDs keep
  identically named realms separate. Whole readable player GUIDs update an
  observed character's renamed entry without parsing GUID components.
- Recents keep the newest 20 successful destinations per sending realm/faction,
  shared across characters in that context. Reusing a recipient moves it to the
  front. Explicit cross-realm destinations preserve their realm suffix.
- Data uses `ForeverUtilitiesDB.mail.characters` and `.recents`. Class positions
  and preferences are preserved. Normal WoW logout handles persistence through
  the existing `SavedVariables` declaration.
- Forgetting an alt removes the local suggestion; logging into it again records
  it again. Forgetting a recipient affects local history, not game mail.

Only character identities and recipient names are stored. Mail subjects,
bodies, attachments, and money amounts are not read or persisted by this helper.
No recipient is inserted merely by opening the panel. A click fills the field;
the user completes the normal sending action and any native confirmation.

## Settings and lifecycle

Every class exposes **Mail recipients: alts and recents**, default on. It is
independent of the class bar's enable setting. English and Simplified Chinese
labels follow the established locale service; client-provided names stay intact.

`MailRecipients.lua` creates one shared event controller when enabled. The
panel is created only when the native Send Mail tab becomes visible. It follows
that tab's visibility, hides in combat or while outside the world, and never
polls. Disabled tracking removes its event listeners. Existing native script
hooks remain installed but their callbacks stay inert while disabled.

Missing, forbidden, or unreadable native frames/identity data leave the panel
hidden. An unavailable native send hook leaves recents empty; the addon does
not infer success from an edited field. Overlapping attempts that cannot be
associated with a single success are omitted from history.

## Verified Forever API evidence

Checked November 8, 2026 against extracted Forever build **1.60.1.70862**, commit
`9dc84f0d3bbae1768ac3405b3716000bd93eda06`. This is a mail-specific source review,
not a complete re-audit of other class APIs or live-game validation.

- [MailFrame.lua](https://github.com/Gethe/wow-ui-source/blob/9dc84f0d3bbae1768ac3405b3716000bd93eda06/Interface/AddOns/Blizzard_MailFrame/MailFrame.lua):
  `SendMailFrame_SendMail` passes the recipient to global `SendMail`.
  `MAIL_SEND_SUCCESS` calls `SendMailFrame_Reset`, which clears the recipient
  edit box. Reading its text only after success would lose the actual name.
  Classmate uses a guarded `hooksecurefunc` post-hook to remember only the
  recipient argument, and commits history only on the success event.
- [MailFrame.xml](https://github.com/Gethe/wow-ui-source/blob/9dc84f0d3bbae1768ac3405b3716000bd93eda06/Interface/AddOns/Blizzard_MailFrame/MailFrame.xml):
  `SendMailFrame` and `SendMailNameEditBox` remain public native names. The Send
  Mail frame is hidden on the inbox tab. Its recipient field retains its native
  text-change handlers; Classmate attaches to visibility with `HookScript`.
- [Mail events](https://github.com/Gethe/wow-ui-source/blob/9dc84f0d3bbae1768ac3405b3716000bd93eda06/Interface/AddOns/Blizzard_APIDocumentationGenerated/MailInfoDocumentation.lua):
  `MAIL_SHOW`, `MAIL_CLOSED`, `MAIL_SEND_SUCCESS`, and `MAIL_FAILED` are declared.
  The success event carries no recipient payload, so it must be associated with
  the previously observed send argument.
- [Secure transfer documentation](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SecureTransferDocumentation.lua):
  transfer operations have restrictions. Classmate does not call secure transfer
  APIs or alter confirmations. `SECURE_TRANSFER_CANCEL` clears a pending history
  candidate; cancellation does not count as a send.
- [Edit box API](https://github.com/Gethe/wow-ui-source/blob/9dc84f0d3bbae1768ac3405b3716000bd93eda06/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleEditBoxAPIDocumentation.lua):
  native text can be restricted. Recipient arguments and identity values are
  checked for secrets before parsing, saving, comparing, or displaying them.

Tests exercise lazy loading, successful sends before/after native field reset,
failures, cancellation, ambiguous attempts, realm/faction separation, renames,
pagination, click-only filling, disabled/forbidden controls, persistence, locale
labels, and disabling/re-enabling across combat/loading. These checks use mocked
APIs. Live validation still needs a mailbox, an observed alt, a successful send,
a failed send, a normal logout/login, and the actual Forever UI scale.
