# cmdWeapons

Simple plugin that sets the spawn weapons/items.

### *Admin Commands:*<br>
Admin flag only, if team choice is admitted 'all' will be used.

### Weapons and Item Commands<br>
---
**!wp {weapon_shortcode} {ct/t/all}** - *Set Weapon* <br>
**!item {item_shortcode} {amount} {ct/t/all}** - *Set item(s)*  <br>
**!onetap {on/off} {ct/t/all}** - *Enable one-tap mode (clip capacity 1)*  <br>
**!hp {amount} {ct/t/all}** - *Set the amount of health a player spawns with*  <br>
### Useful Commands <br>
---
**!flip** - *Switch settings for both sides*  <br>
**!clear** - *Clear all settings*  <br>
**!rr** - *Restart Round* <br>
### Save your config <br>
----
**!save {save_name}** - *Save all current settings* <br>
**!load {save_name}** - *Load existing settings* <br>
**!delete {save_name}** - *Delete an existing slot* <br>
**!update {save_name}** - *Update an existing slot* <br>
### Custom Settings <br>
---
Save your own console commands and execute them at any time, you must remember to wrap the commands in quotation marks, i.e: <br>
!rcon_save bunnyhop "sv_cheats 1; sv_enablebunnyhopping 1; sv_autobunnyhopping 1"
<br><br>
If your commands are too long for the chat box, enter it via the console instead omitting the **!**, i.e:<br>
rcon_save bunnyhop "sv_cheats 1; sv_enablebunnyhopping 1; sv_autobunnyhopping 1"<br><br>
**!rcon_save {save_name} {console commands}** - *Save custom console commands* <br>
**!rcon_load {save_name}** - *Load and execute custom console commands* <br>
**!rcon_delete {save_name}** - *Delete an existing slot* <br>
**!rcon_update {save_name} {console commands}** - *Update an existing slot* <br>

### Shortcodes <br>
---
**Weapons** <br>
awp, scout, ak, m4, m4s, sg, aug, deag, usp, glock, galil, famas, mac10, mp9, mp7, ump, bizon, p90, mp5, m249, mag7, negev, nova, shorty, xm, 57, dualies, p250, tec9, cz, r8, p2000<br><br>
**Items** <br>
grenade, smoke, flash, decoy, charge, mine, tag, snowball, shield, defuser
