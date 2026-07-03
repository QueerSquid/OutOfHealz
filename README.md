# OutOfHealz

OutOfHealz is a World of Warcraft addon focused on one thing:

Keeping you aware when you are out of healer range during combat.

The addon monitors healer proximity in real time during combat and provides both visual and audio warnings when no healer is detected within range.

---

# Current Features

* Combat-only healer range monitoring
* Visual out-of-range warning system
* Escalating warning text
* Escalating sound alerts
* Healer role detection
* LibRangeCheck-3.0 integration for combat-safe range detection
* Native Blizzard AddOns configuration panel
* Live warning frame scale adjustment
* Toggleable sound alerts
* Toggleable instance-only mode
* PvP behavior setting (future functionality)
* Draggable warning frame
* Persistent saved frame positioning
* Slash command support
* Frame reset support

---

# Slash Commands

| Command | Function |
|----------|----------|
| `/ooh` | Display available commands |
| `/ooh config` | Open the OutOfHealz options panel |
| `/ooh options` | Open the OutOfHealz options panel |
| `/ooh settings` | Open the OutOfHealz options panel |
| `/ooh hide` | Hide the warning frame |
| `/ooh unlock` | Unlock and move the warning frame |
| `/ooh lock` | Lock the warning frame |
| `/ooh reset` | Reset the warning frame position |
| `/ooh instance` | Toggle instance-only mode |
| `/ooh instance on` | Enable instance-only mode |
| `/ooh instance off` | Disable instance-only mode for testing |
| `/ooh sound` | Toggle sound alerts |
| `/ooh sound on` | Enable sound alerts |
| `/ooh sound off` | Disable sound alerts |

Full command aliases:

```text
/ooh
/outofhealz
```

---

# Installation

1. Download or install through CurseForge
2. Place the `OutOfHealz` folder into:

```text
World of Warcraft/_retail_/Interface/AddOns/
```

3. Launch or reload WoW
4. Enable OutOfHealz from the AddOns menu

---

# Current Development Status

OutOfHealz is currently released and actively maintained.

Core functionality has been validated through live dungeon and raid testing. Current development is focused on expanding customization options and additional survivability features.

---

# Planned Features

## High Priority

* Health threshold warnings
* Health potion reminder
* Healthstone reminder
* PvP behavior implementation
* Additional class/spec-aware warning behavior

## Quality of Life

* Sound packs
* Additional visual customization
* Enhanced warning frame customization

## Future

* Standalone configuration window
* Optional minimap launcher

---

# Known Notes

* Instance-only mode is enabled by default.
* All configuration options are available through the Blizzard AddOns settings panel or `/ooh config`.
* Slash commands remain fully supported.
* LibRangeCheck-3.0 is used for combat-safe healer range detection due to Blizzard API limitations.

---

# Credits

Created by QueerSquid.

Built for PvE players who occasionally forget healers exist until it is already too late.
