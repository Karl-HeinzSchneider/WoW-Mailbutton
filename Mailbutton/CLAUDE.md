# Mailbutton addon

Load order: embeds.xml, core logger/db/ace, mail recipients/buttons, options, Mailbutton.lua.
Keep MailbuttonDB and factionrealm.nameTable compatible with existing installations.
Recipient storage is a map; sort a separate array for display. Mail UI may be loaded on demand.
Do not create controls until SendMailFrame and SendMailNameEditBox exist.
Core and tooling follow the repository CLAUDE.md. There is no minimap module.
src/options.lua implements the recipient editor, import/export, and Blizzard settings registration.
Vendored libraries are limited to the embeds.xml load graph: LibStub, CallbackHandler,
AceAddon, AceEvent, AceDB, and AceConsole. The settings panel uses native controls.
