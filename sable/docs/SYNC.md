# Keeping in step with Marathon

SableOS Native carries Marathon-Shell's full history and merges new Marathon
work regularly, so that Q25 hardware fixes arrive here without being redone.

## Remotes and branches

| Name | What it is |
|---|---|
| `origin` | `github.com/sableos-project/sableos-native` |
| `upstream` (remote) | `github.com/patrickjquinn/Marathon-Shell` |
| `upstream` (branch) | Mirror of Marathon's `release/q25-v1`; never committed to by hand |
| `main` | SableOS Native |

One-time setup in a fresh clone:

```sh
git remote add upstream https://github.com/patrickjquinn/Marathon-Shell.git
git config remote.upstream.tagOpt --no-tags
```

## Weekly sync (and at once for every Marathon Q25 release)

```sh
git fetch upstream release/q25-v1
git push origin upstream/release/q25-v1:upstream   # update the mirror branch
git switch -c sync/$(date +%Y%m%d) origin/main
git merge --no-ff upstream/release/q25-v1
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
