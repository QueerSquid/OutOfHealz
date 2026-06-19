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
* Draggable warning frame
* Persistent saved frame positioning
* Sound alert toggles
* Slash command support
* Frame reset support
* Dugeon and raid-focused operation

---

# Slash Commands

| Command             | Function                                          |
| ------------------- | ------------------------------------------------- |
| `/ooh hide`         | Hides the warning frame                           |
| `/ooh unlock`       | Unlocks the warning frame for movement            |
| `/ooh lock`         | Locks the warning frame                           |
| `/ooh reset`        | Resets the warning frame position                 |
| `/ooh instance`     | Toggles instance-only mode                        |
| `/ooh instance on`  | Enables instance-only mode                        |
| `/ooh instance off` | Disables instance-only mode for testing           |
| `/ooh sound`        | Toggle sound alerts                               |
| `/ooh sound on`     | Enable sound alerts                               |
| `/ooh sound off`    | Disable sound alerts                              |

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

---

# Planned Features

* Adjustable warning scale
* Additional visual customization
* Options/settings panel
* Health threshold warning
* Healthstone / health pot / defensive reminder
* Possible class/spec-aware warning behavior

---

# Known Notes

* Instance-only mode is enabled by default.
* OutOfHealz is designed primarily for dungeon and raid content.
* Instance-only mode can be disabled manually for testing purposes with `/ooh instance off`.
* LibRangeCheck-3.0 is used due to combat limitations and taint issues with Blizzard range APIs.

---

# Credits

Created by QueerSquid.

Built for PvE players who occasionally forget healers exist until it is already too late.
