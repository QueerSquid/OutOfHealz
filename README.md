# OutOfHealz: Survivability Assistant

OutOfHealz is a lightweight combat survivability assistant for World of Warcraft Retail.

Originally built as a healer-range warning addon, OutOfHealz now combines positioning awareness, low-health warnings, and actionable consumable reminders to help players recognize dangerous situations before they become preventable deaths.

The goal is simple:

**Warning → Recommendation → Guidance**

OutOfHealz does not attempt to replace encounter addons, rotation helpers, or player decision-making. It focuses specifically on providing useful survivability information when it matters.

---

## Features

### Healer Range Warning

OutOfHealz monitors healer range while you are in combat and warns when it can confirm that no detected healer is within healing range.

Warnings escalate the longer you remain outside healer range:

- OUT OF HEAL RANGE
- STILL OUT OF HEAL RANGE
- IF YOU DIE, IT'S YOUR FAULT

Optional audio alerts provide additional feedback without requiring constant attention to the warning frame.

### Low Health Warning

A configurable low-health warning provides immediate visual feedback when your health falls below a selected threshold.

- Configurable threshold from 10% to 75%
- Enabled or disabled independently
- Combat-only behavior
- Supports Instance Only mode
- Independent movable warning frame

### Health Potion Reminder

When your health drops below the configured health threshold, OutOfHealz can display an actionable Health Potion reminder.

- Detects the strongest supported Health Potion currently available
- Supports Midnight and The War Within healing potions
- Only displays when a supported potion is available and ready, prioritizing current season potions
- Displays the potion's actual item icon
- Item tooltip support
- Secure click-to-use functionality during combat
- Independent cooldown and availability tracking

### Healthstone Reminder

OutOfHealz can also detect and recommend available Healthstones.

- Supports regular Healthstones
- Supports Demonic Healthstones
- Prioritizes Demonic Healthstones when available
- Independent availability and cooldown tracking
- Item icon and tooltip support
- Secure click-to-use functionality during combat
- Can appear alongside the Health Potion reminder

### Consumable Reminder Cluster

Health Potion and Healthstone reminders are grouped into a shared survivability cluster.

- Consistent spacing at different UI scales
- Shared positioning through the Health Potion reminder
- Persistent position between sessions
- Supports reset and unlock commands
- Secure combat actions remain separated from visual warning frames

### Configuration

OutOfHealz provides two configuration interfaces:

- A standalone settings window with General, Health, Consumables, and Display sections.
- A native Blizzard AddOns settings panel.

The standalone window automatically previews warning frames while configuration is open. A draggable minimap launcher provides quick access to both interfaces.

Current options include:

- Enable Sound Alerts
- Instance Only
- Enable in PvP
- Show Minimap Button
- Enable Low Health Warning
- Low Health Threshold
- Enable Health Potion Reminder
- Enable Healthstone Reminder
- Warning Scale
- Display currently detected Health Potion and Healthstone names
- Refresh detected consumable information when inventory or item data changes

The PvP option is currently reserved for future PvP-specific behavior.

---

# Slash Commands

| Command | Function |
|----------|----------|
| `/ooh` | Display available commands |
| `/ooh config` | Open the standalone settings window |
| `/ooh options` | Open the standalone settings window |
| `/ooh settings` | Open the standalone settings window |
| `/ooh hide` | Hide the warning frames |
| `/ooh unlock` | Unlock warning frames for repositioning |
| `/ooh lock` | Lock warning frames in place |
| `/ooh reset` | Reset warning frame positions |
| `/ooh instance` | Toggle instance-only mode |
| `/ooh instance on` | Enable instance-only mode |
| `/ooh instance off` | Disable instance-only mode for testing |
| `/ooh sound` | Toggle sound alerts |
| `/ooh sound on` | Enable sound alerts |
| `/ooh sound off` | Disable sound alerts |
| `/ooh debughealth` | Display health warning, consumable, and cooldown diagnostic information |

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

OutOfHealz is actively maintained.

Version 2.1.0 expands the addon with clickable Health Potion and Healthstone reminders, a standalone configuration window, minimap launcher, and improved warning-frame positioning and scaling.

Core functionality has been validated through live dungeon and raid testing. Further development will focus on survivability recommendations, defensive reminders, and configuration improvements.

---

# Design Philosophy

OutOfHealz is evolving from a healer-range warning into a broader combat survivability assistant.

Development follows a simple progression:

**Warning → Recommendation → Guidance**

Each feature is evaluated around one question:

> What information can OutOfHealz provide right now that gives the player the best chance to stay alive?

OutOfHealz is intentionally focused on survivability rather than damage optimization, encounter timers, or rotation assistance.

---

# Planned Features

## Survivability

* Resource-aware survivability recommendations
* Defensive cooldown reminders
* Smarter warning escalation and prioritization
* Class and specialization-aware behavior
* Role-aware recommendations
* PvP behavior implementation

## Configuration & Quality of Life

* Improved warning frame positioning and customization
* Native settings warning-frame preview toggle
* WoW Edit Mode integration research
* Additional visual customization
* Individual sound selection and additional sound options

## Future

* Additional healer positioning information where permitted by the WoW API
* Accessibility presets and additional customization options

---

# Known Notes

* Instance-only mode is enabled by default.
* All configuration options are available through the Blizzard AddOns settings panel or `/ooh config`.
* Slash commands remain fully supported.
* LibRangeCheck-3.0 is used for combat-safe healer range detection due to Blizzard API limitations.
* Healer range information may become less precise during combat due to World of Warcraft API restrictions. When OutOfHealz cannot reliably determine healer range, it reports `HEALER RANGE UNKNOWN` in chat and suppresses out-of-range warnings rather than generating a potentially false alert.
* No healer-range warning means OutOfHealz has not confirmed that you are out of healer range; it does not necessarily guarantee that a healer is within range.
* Health Potion and Healthstone reminders use secure action buttons so consumables can be clicked during combat.
* Due to WoW combat-lockdown and secret-health restrictions, consumable click regions cannot be dynamically enabled or disabled based on health while combat is active. Position the consumable reminder cluster somewhere that does not interfere with important UI elements or world interaction.
* Regular Healthstone functionality has been validated in live gameplay, including combat use, cooldown behavior, independent triggering, and inventory depletion.
* Demonic Healthstone support is implemented but has not yet received the same level of live testing.

---

# Credits

Created by **QueerSquid**.

Special thanks to **Treesnake-Dalaran** for helping provide Healthstones for development and testing.

Built for PvE players who occasionally forget healers exist until it is already too late.
