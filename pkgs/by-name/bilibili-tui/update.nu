#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

let repo = "MareDevi/bilibili-tui"
let pkg = "pkgs/by-name/bilibili-tui/package.nix"
let fake = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
let headers = if ($env.GITHUB_TOKEN? | is-empty) { [Accept application/json] } else { [Authorization $"Bearer ($env.GITHUB_TOKEN)"] }
let version = http get --headers $headers $"https://api.github.com/repos/($repo)/releases/latest" | get tag_name | str substring 1..
if $version == $env.UPDATE_NIX_OLD_VERSION { exit 0 }
let hash = ^nix store prefetch-file --unpack --json $"https://github.com/($repo)/archive/refs/tags/v($version).tar.gz" | from json | get hash

open --raw $pkg
| str replace --regex 'version = "[^"]+"' $'version = "($version)"'
| str replace --regex '\bhash = "[^"]+"' $'hash = "($hash)"'
| str replace --regex 'cargoHash = "[^"]+"' $'cargoHash = "($fake)"'
| save --force $pkg

let cargo = ^nix build --no-link .#bilibili-tui.cargoDeps | complete | get stderr | parse --regex 'got:\s+(\S+)' | first | get capture0
open --raw $pkg | str replace $fake $cargo | save --force $pkg
