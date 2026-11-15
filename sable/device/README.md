# sable/device

One folder per phone. A device backend holds everything that differs between
phones: kernel and boot pins, key map and key meanings, gesture thresholds,
modem and call-audio packages, service units, display profile, image and OTA
configuration. Nothing else under `sable/` may depend on a specific phone.

| Folder | Phone | Platform | Status |
|---|---|---|---|
| `zinwa-q25/` | Zinwa Q25 | Marathon (MT6789, Linux 7.0 fork) | Active |
| `unihertz-titan2/` | Unihertz Titan 2 | Serlk's mainline Linux (MT6878, 7.2) | On hold |
