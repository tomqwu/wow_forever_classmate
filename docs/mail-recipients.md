# Mail recipients: alts and recents

Classmate 0.30.1 provides a compact side panel to the native **Send Mail** tab. It
shows both **Alts** and **Recent recipients**, with five rows and independent
pagination for each list. Click a name to fill the recipient field; right-click
to forget its saved record. Names include both first name and surname, with wrapping inside the existing row size and complete addresses on hover.

## Discovery and persistence

- Log into each character once with Classmate and its mail feature enabled.
  The addon records that observed character; it cannot enumerate the account's
  unplayed roster. The current character is excluded from its own alt list.
- Alts are filtered to the current realm and faction. Readable realm IDs keep
  identically named realms separate. Whole readable player GUIDs update an
  observed character's renamed entry without parsing GUID components.
- Recents keep the newest 20 successful destinations per sending realm/faction,
  shared across characters in that context. Reusing a recipient moves it to the
  front. The complete successful native address is retained unchanged; the helper does not interpret a surname as a realm or append a guessed realm.
- Data uses `ForeverUtilitiesDB.mail.characters` and `.recents`. Class positions
  and preferences are preserved. Normal WoW logout handles persistence through
  the existing `SavedVariables` declaration.
- Forgetting an alt removes the local suggestion; logging into it again records
  it again. Forgetting a recipient affects local history, not game mail.

Only character identities and recipient names are stored. Mail subjects,
bodies, attachments, and money amounts are not read or persisted by this helper.
No recipient is inserted merely by opening the panel. A click fills the field;
the user completes the normal sending action and any native confirmation.

## Forever names and migration from 0.30.0

Forever uses two-part character names. Read the full native name with
`GetUnitName('player')`. Its `UnitName`, `UnitNameUnmodified`, and `UnitFullName`
tuples return first name and surname; the second value must not be treated as a
realm. Classmate falls back to joining two readable `UnitFullName` components
only when a complete native name is unavailable. Actual realm context still
comes from the independent realm APIs.

The lists and clicked recipient include the full name. A one-part name is not
eligible for a suggestion. Recent addresses are retained as observed on a
successful send; spacing/hyphen spelling may normalize for deduplication without
changing the stored address used by a click.

Version 0.30.0 recorded incomplete alt names and could append a supposed realm
to recent recipients. Those strings cannot reliably reveal a missing surname.
With `mail.nameFormat=2`, old recent lists are preserved under `.legacyRecents`
but stay outside active history. Old alt records stay hidden until the alt logs
in again. A readable matching player GUID replaces that character's old entry;
other character records and class preferences remain intact. Future successful
sends rebuild complete-name history normally.

Evidence checked November 8, 2026:

- [Blizzard's naming overview](https://worldofwarcraft.blizzard.com/en-gb/news/24304161/create-a-name-of-your-own-in-wow-forever)
  confirms first and second names together identify a character within a region.
- [The AllTheThings author's observed API results](https://github.com/ATTWoWAddon/AllTheThings/issues/2630)
  document the surname tuple behavior and full `GetUnitName` string. These are
  author-reported client observations; generated documentation still labels a
  tuple field as a server, so its field name is not proof of Forever behavior.
- [Bulk Mail's Forever correction](https://www.wowace.com/projects/bulkmail/files/8999065)
  independently records a first-name-only self-check failure and its switch to
  the complete `GetUnitName` result.
- The user's November 8 screenshot shows Classmate 0.30.0 listing and filling
  only the first name, which reproduced the faulty code path.

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
