# Zinwa Q25 backend

720x720 IPS at scale 1.5, BlackBerry Classic keyboard, trackpad, Call / Menu /
Back / End keys. Kernel, boot (U-Boot, systemd-boot), modem (`mtk-ccci`
ModemManager package), audio and OTA come from Marathon unchanged.

| File | Schema | What it sets |
|---|---|---|
| `flow.toml` | `sable-settings::FlowConfig` | Edge zone and thresholds for minimise and Hub peek |
| `keys.toml` | `sable-settings::KeysConfig` | Press and hold meanings of the phone keys |

Install path on the phone: `/etc/sableos/`.
