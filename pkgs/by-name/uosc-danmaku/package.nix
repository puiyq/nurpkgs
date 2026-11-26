{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "uosc-danmaku";
  version = "0-unstable-2026-11-25";

  src = fetchFromGitHub {
    owner = "Tony15246";
    repo = "uosc_danmaku";
    rev = "74ade6cbed91bd58aee219010ded9d96598262cf";
    hash = "sha256-b8CLOHc9Nje03Q6ePAwrNdqCBFKyyGXj251Clt2XoZQ=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 main.lua $out/share/mpv/scripts/uosc_danmaku/main.lua
    cp -r modules apis dicts sites $out/share/mpv/scripts/uosc_danmaku/

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.nu;
    scriptName = "uosc_danmaku";
  };

  meta = {
    description = "Load DanDanPlay danmaku in MPV player";
    homepage = "https://github.com/Tony15246/uosc_danmaku";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
  };
})
