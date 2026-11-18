#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell

# nix-update runs this from the repository root
const PKG = "pkgs/by-name/uosc-danmaku/package.nix"
const REPO = "Tony15246/uosc_danmaku"

let content = open --raw $PKG

let old = $content
| parse --regex '(?s)version = "(?P<version>[^"]+)".*?rev = "(?P<rev>[^"]+)".*?hash = "(?P<hash>[^"]+)"'
| first

let headers = $env.GITHUB_TOKEN? | default "" | if $in == "" { {} } else { {Authorization: $"Bearer ($in)"} }
let head = http get --headers $headers $"https://api.github.com/repos/($REPO)/commits/HEAD"
if $head.sha == $old.rev {
    print -e "Already up-to-date"
    exit 0
}

let version = $"0-unstable-($head.commit.committer.date | into datetime | format date '%Y-%m-%d')"

let hash = (
    ^nix --extra-experimental-features "nix-command flakes" store prefetch-file --unpack --json
        $"https://github.com/($REPO)/archive/($head.sha).tar.gz"
    | from json
    | get hash
)

$content
| str replace $old.version $version
| str replace $old.rev $head.sha
| str replace $old.hash $hash
| save --force $PKG
print -e $"Updated: ($old.version) -> ($version)"
