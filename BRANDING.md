# Branding: where "Marathon" is replaced

SableOS Native may not use "Marathon" as its product name or logo (Apache-2.0
grants no trademark rights). This file lists every place where a user can see
the product name, and whether it has been changed. Internal names stay as
they are so that merges from upstream keep working.

## Keep as Marathon (internal, never shown as the product name)

| Kind | Examples | Why |
|---|---|---|
| D-Bus names | `org.marathonos.Shell`, `org.marathonos.Telephony` | Apps and daemons depend on them; renaming breaks merges |
| Package and crate names | `marathon-shell`, `marathon-telephonyd`, `marathon-apps` | Same |
| Source paths | `shell/`, `crates/marathon-*`, `marathon-silica/` | Same |
| Credits | `LICENSE`, `NOTICE`, about-page credits | Attribution is required |

New SableOS names use `org.sableos.*` (D-Bus) and `sable-*` (packages, crates).

## Replace with SableOS (seen by users)

| Where | Status |
|---|---|
| Boot splash and logo | To do |
| OOBE (setup) welcome text | To do |
| Settings > About device: product name | To do |
| OS release file (`/etc/os-release` NAME, ID) | To do |
| Store and update channel names | To do |
| Image and release file names (`sableos-native-*`) | To do |
| App icon theme name, default wallpaper | To do |

Each change is made through a hook listed in `sable/docs/HOOKS.md`, or as a
new file under `sable/`, never by renaming Marathon's internals.

## Release tags

Marathon's `.github/workflows/release.yml` runs on tags named `v*`. SableOS
Native release tags use `sableos-native-<marathon build>-<n>` so that they
never start Marathon's release job.
