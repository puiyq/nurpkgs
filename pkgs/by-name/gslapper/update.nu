#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

let repo = "Nomadcxx/gSlapper"
let pkg = "pkgs/by-name/gslapper/package.nix"

let headers = if ($env.GITHUB_TOKEN? | is-empty) { [Accept application/json] } else { [Authorization $"Bearer ($env.GITHUB_TOKEN)"] }
let version = http get --headers $headers $"https://api.github.com/repos/($repo)/releases/latest" | get tag_name | str substring 1..
if $version == $env.UPDATE_NIX_OLD_VERSION { exit 0 }
let hash = ^nix store prefetch-file --unpack --json $"https://github.com/($repo)/archive/refs/tags/v($version).tar.gz" | from json | get hash

open --raw $pkg
| str replace --regex 'version = "[^"]+"' $'version = "($version)"'
| str replace --regex '\bhash = "[^"]+"' $'hash = "($hash)"'
| save --force $pkg
