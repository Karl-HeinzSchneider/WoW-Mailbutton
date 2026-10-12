# Mailbutton project instructions

Mailbutton is a Lua 5.1 WoW addon using the WoW-AddonTemplate layout.
The distributable lives in Mailbutton/; root src/ holds TypeScript tooling.
Read Mailbutton/CLAUDE.md before editing runtime code.

Preserve MailbuttonDB and its AceDB factionrealm.nameTable name-to-true map.
Keep runtime state in the private addon table. List every runtime file in the TOC.
Initialize saved data only in OnInitialize. Detect mail UI availability before using it.
Keep code compatible with Lua 5.1 and avoid client-specific templates or mixins.
Reference the read-only client exports in E:/Projects/_data when changing API calls.

Commands: npm install; npm run format; npm run check; npm test;
npm run package:addons; npm run dev:link -- "<WoW>/Interface/AddOns".
Lua checks require a Lua 5.1 compiler; newer installed Lua only provides partial verification.
XML schema validation is skipped when the configured export is absent; report that limitation.
Root tooling, docs and tests must be ignored in .pkgmeta. Libraries are vendored; do not patch.
Release workflows use BigWigs packager and @project-version@; never release without user request.
