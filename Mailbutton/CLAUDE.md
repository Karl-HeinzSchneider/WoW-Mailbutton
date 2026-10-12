# Mailbutton addon

Load order: embeds.xml, core logger/db/ace, mail recipients/buttons, Mailbutton.lua.
Keep MailbuttonDB and factionrealm.nameTable compatible with existing installations.
Recipient storage is a map; sort a separate array for display. Mail UI may be loaded on demand.
Do not create controls until SendMailFrame and SendMailNameEditBox exist.
Core and tooling follow the repository CLAUDE.md. There is no minimap or settings module.
