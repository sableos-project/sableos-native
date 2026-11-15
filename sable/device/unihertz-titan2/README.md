# Unihertz Titan 2 backend (on hold)

Titan 2 OS development is on hold under the SableOS device portfolio decision of
3 November 2026. Only a source-only portability assessment is allowed; no
images, flashing or device work.

When the hold is lifted, this backend would build on Serlk's mainline Linux
(MT6878, Linux 7.2, https://github.com/Serlk/titan2-tools) and on Marathon's
announced Titan 2 port. Rules already known:

- Keep Serlk's ModemManager and `mtk-ccci` plugin pair as tested; adapt
  SableOS and Marathon to it, never replace it with the Q25 package.
- Keep `t2-speechd` and its Voice Call UCM routing for call audio.
- Keep the start order `t2-modem` -> ModemManager -> `t2-speechd`.
- 1440x1440 main display; the rear display is optional.
