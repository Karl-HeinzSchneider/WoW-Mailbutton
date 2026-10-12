# Mailbutton

Saved recipient shortcuts beside the send-mail form. Click a name to fill the recipient,
Clear to clear it, + to add a character, and - to show removal buttons. More than eight
recipients are accessible with the page arrows. Mailbutton never sends mail automatically.

Commands: `/mb`, `/mailbutton`, `/mb add Name-Realm`, `/mb remove Name-Realm`, `/mb list`,
`/mbadd Name`, `/mbremove Name`.

Install the `Mailbutton/` directory inside `Interface/AddOns`. The repository root is tooling.
Existing `MailbuttonDB` remains compatible: recipients are stored as name-to-true entries in
AceDB's faction/realm scope. Names retain their spelling, including accented characters.

Targets: Forever (16001), Retail, progression Classic, Anniversary and Era. The exported
Classic UI uses SendMailFrame and SendMailNameEditBox; creation waits until those exist.
The retail export provided is incomplete, so the mail API was also checked against the
[current UI source](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_MailFrame/MailFrame.lua).
Interface numbers must be refreshed as clients update; enable out-of-date addons if necessary.

Development: `npm install`, `npm run format`, `npm run check`, `npm run package:addons`.
Link a client with `npm run dev:link -- "<WoW>/Interface/AddOns"`.

Manual validation still required on each client: login with existing saved data, open mailbox,
switch tabs, add/select/clear/delete names, page through nine recipients, close/reopen mailbox,
reload, and verify faction/realm isolation and coexistence with other mail addons.

Forever recipients may include first and last names: `/mb add Peter Maier` or `/mbadd Peter Maier`.

Open Blizzard Settings > AddOns > Mailbutton, click the mailbox gear, or use `/mb options`.
Edit the list with one full recipient name per line and click Save to replace the buttons
(an empty list clears them). Export loads the saved list for Ctrl+A / Ctrl+C; paste a list
with Ctrl+V and click Import to add names while keeping existing buttons. Invalid lists
leave saved names unchanged. Reopening the panel reloads saved names and discards unsaved edits.
