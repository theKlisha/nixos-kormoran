{ pkgs, name }:
let
  versions = pkgs.lib.importJSON ./versions.json;
  server = pkgs.fetchurl versions.server;
  mods = builtins.mapAttrs (_: pkgs.fetchurl) versions.mods;
in
pkgs.stdenv.mkDerivation {
  name = name;
  pname = name;

  srcs = [ server ] ++ builtins.attrValues mods;
  dontUnpack = true;

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/minecraft
    install -Dm644 ${server} $out/lib/minecraft/minecraft-server.jar

    mkdir -p $out/lib/minecraft/mods
    ${pkgs.lib.pipe mods [
      (builtins.mapAttrs (name: mod: "install -Dm644 ${mod} $out/lib/minecraft/mods/${name}.jar"))
      (builtins.attrValues)
      (pkgs.lib.concatStringsSep "\n")
    ]}

    makeWrapper ${pkgs.lib.getExe pkgs.jre_headless} $out/bin/minecraft-server \
      --append-flags "-jar $out/lib/minecraft/minecraft-server.jar nogui" \
      ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [ pkgs.udev ]
      }"}

    runHook postInstall
  '';
}
