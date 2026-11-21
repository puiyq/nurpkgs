def main [] { help main }

def version [package: string] { ^nix eval --raw $".#($package).version" }

def "main list" [] {
    glob pkgs/by-name/*/update.nu | each { path dirname | path basename } | append "flake-lock" | to json --raw
}

def "main update" [target: string] {
    let branch = $"automated/update-($target)"

    if (^git ls-remote --exit-code --heads origin $branch | complete | get exit_code) == 0 {
        ^git fetch origin $branch
        ^git checkout -B $branch $"origin/($branch)"
    } else {
        ^git checkout -b $branch
    }

    let message = if $target == "flake-lock" {
        ^nix flake update
        "flake.lock: update inputs"
    } else {
        let old = version $target
        $env.UPDATE_NIX_ATTR_PATH = $target
        $env.UPDATE_NIX_OLD_VERSION = $old
        run-external $"pkgs/by-name/($target)/update.nu"
        $"($target): ($old) -> (version $target)"
    }

    ^nix fmt
    if (^git status --porcelain | is-empty) { return }

    ^git -c user.name=github-actions[bot] -c user.email=41898282+github-actions[bot]@users.noreply.github.com commit -am $message
    ^git push origin $branch

    if (^gh pr list --head $branch --json number | from json | is-empty) {
        ^gh pr create --head $branch --fill
    }
}
