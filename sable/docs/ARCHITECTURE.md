# SableOS Native architecture (summary)

SableOS Native changes two layers of Marathon OS: the QML inside Marathon's
shell process, and a set of new Rust daemons. Apps, the compositor, Marathon's
own daemons and the OS base are reused. The full architecture and design
document is maintained by the SableOS Project; this file is the in-repo summary.

```text
Apps (Wayland clients)      SableOS apps | Keel apps | Flatpak / native | Android (Deckard)
        | Wayland
Shell process (Qt 6, QML)   Compositor (Marathon) | Flow | Hub view | Frames | Key router
        | session D-Bus
Rust daemons                sable-hubd | sable-framesd | sable-inputd | sable-searchd
                            + Marathon: telephonyd, maild, davd, pilotd
        | system D-Bus, input events
Device backend              sable/device/<device>/: kernel, boot, modem, audio, keys, image
```

## Rules

- Only the device backend changes per phone. Shell QML, `Sable.Components`, the
  Rust daemons and the apps must not check which phone they run on; device facts
  come from the backend's profile files (`flow.toml`, `keys.toml`, ...).
- Sizes are density-independent units, never pixels: the same layout serves the
  Q25 (720x720, scale 1.5) and the Titan 2 (1440x1440).
- Daemons reach hardware only through system services (ModemManager,
  NetworkManager, UPower). Only the shell owns windows, input focus and the
  cgroup freezer.
- New D-Bus names use `org.sableos.*`; Marathon's `org.marathonos.*` interfaces
  are used as they are.
- Edition-neutral contracts (Hub portability, normalized key input,
  keyboard-first device profile, portability rules, device support levels) live
  in [sableos-project/platform_sable](https://github.com/sableos-project/platform_sable)
  and are implemented here.

## Planned Rust daemons

| Crate | Bus name | Job | Status |
|---|---|---|---|
| `sable-settings` | (library) | Schemas, defaults, validation for device and user settings | Started |
| `sable-hubd` | `org.sableos.Hub1` | Merges SMS, calls, mail, calendar, notifications into the Hub | Planned |
| `sable-framesd` | `org.sableos.Frames1` | Which apps stay live as frames, cover refresh, freezing policy | Planned |
| `sable-inputd` | `org.sableos.Input1` | Key meanings, list shortcuts, AutoText, speed dial | Planned |
| `sable-searchd` | `org.sableos.Search1` | Universal search over apps, contacts, Hub, settings | Planned |
