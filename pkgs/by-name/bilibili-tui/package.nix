{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  makeBinaryWrapper,
  aws-lc,
  openssl,
  cacert,
  mpv-unwrapped,
  yt-dlp-light,

  withMpv ? true,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bilibili-tui";
  version = "1.1.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "MareDevi";
    repo = "bilibili-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K9l+ScWACmlaWaQS1dDs9ia5lHVLZ/GssqttTyla91Q=";
  };

  cargoHash = "sha256-F5zxa4euSZUnLBNvtyct3aHKNyWTig9k7diNG52zEw0=";

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [ aws-lc ] ++ lib.optional (!stdenv.hostPlatform.isDarwin) openssl;

  nativeCheckInputs = [ cacert ];

  # Wrap mpv as fallback; users should prefer their system's mpv in PATH
  postInstall = lib.optionalString withMpv ''
    wrapProgram $out/bin/bilibili-tui \
      --suffix PATH : ${
        lib.makeBinPath [
          mpv-unwrapped
          yt-dlp-light
        ]
      }
  '';

  passthru.updateScript = ./update.nu;

  meta = {
    description = "Terminal user interface (TUI) client for Bilibili";
    homepage = "https://maredevi.moe/projects/bilibili-tui/";
    downloadPage = "https://github.com/MareDevi/bilibili-tui/releases";
    changelog = "https://github.com/MareDevi/bilibili-tui/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    mainProgram = "bilibili-tui";
  };
})
