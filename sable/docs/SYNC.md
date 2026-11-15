# Keeping in step with Marathon

SableOS Native carries Marathon-Shell's full history and merges new Marathon
work regularly, so that Q25 hardware fixes arrive here without being redone.

## Remotes and branches

| Name | What it is |
|---|---|
| `origin` | `github.com/sableos-project/sableos-native` |
| `upstream` (remote) | `github.com/patrickjquinn/Marathon-Shell` |
| `upstream` (branch) | Mirror of Marathon's `main` (its latest stable; Marathon's OTA releases are built from it); never committed to by hand |
| `main` | SableOS Native |

One-time setup in a fresh clone:

```sh
git remote add upstream https://github.com/patrickjquinn/Marathon-Shell.git
git config remote.upstream.tagOpt --no-tags
```

## Weekly sync (and at once for every Marathon Q25 release)

Marathon's `main` is its latest stable branch and the base of its OTA
releases (Patrick Quinn, 2026-11-15). Until then SableOS Native followed
`release/q25-v1`, which `main` contains.


```sh
git fetch upstream main
git push origin upstream/main:upstream   # update the mirror branch (admin only)
git switch -c sync/$(date +%Y%m%d) origin/main
git merge --no-ff upstream/main
cd sable/crates && cargo test && cd -              # plus Marathon's CI on the PR
```

Open a pull request from the `sync/` branch into `main`. Merge, never rebase:
`main` must keep Marathon's commits as they are so later merges stay small.
Marathon's tags are not fetched; SableOS Native has its own tag scheme
(`BRANDING.md`).

## Conflicts

- A conflict outside `sable/` means a hook changed in Marathon. Keep Marathon's
  version, re-apply the hook, and update `sable/docs/HOOKS.md`.
- If the same hook conflicts twice, propose it upstream to Marathon.

## What goes back upstream

Bug fixes, Q25 hardware fixes and the small hooks themselves, as pull requests
to Marathon-Shell. The BB10 look and behaviour stay here.

## Fixing Marathon's own code: one commit, two destinations

A fix to a Marathon file (not BB10 work) is written once, on a branch based on
Marathon's `main`, and the same commit goes both upstream and into SableOS
Native. Git then sees identical changes when Patrick merges it, so the next
sync does not conflict and nothing is maintained twice.

One-time setup in a `sableos-native` clone:

```sh
git remote add fork https://github.com/aimindseye/Marathon-Shell.git
```

For each fix:

```sh
git fetch upstream main
git switch -c fix/<topic> upstream/main     # Patrick's code, not ours
# edit, test (sable/scripts/build-marathon.sh), commit with a Conventional subject
git push fork fix/<topic>                   # open the PR to patrickjquinn/Marathon-Shell:main
git push origin fix/<topic>                 # open a PR into sableos-native main if we need it now
```

Record the change in `HOOKS.md` with the upstream PR or issue. When Patrick
merges it, the next sync brings his copy in; then delete the row.

Never base a fix for upstream on our `main`: it would carry `sable/` files and
our hooks into the PR.
