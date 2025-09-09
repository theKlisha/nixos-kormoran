{ pkgs, name, }:
let 
  fabricServer = pkgs.fetchurl {
    url = "https://meta.fabricmc.net/v2/versions/loader/1.21.5/0.17.2/1.1.0/server/jar";
    hash = "sha256-YzND6Pwi1ikIybi4iX99SYF9+ScJ6cyyauWcy+CHhvQ=";
  };

  mods = {
    fabricApi = pkgs.fetchurl {
      url = "https://github.com/zlainsama/OfflineSkins/releases/download/1.21.5-v1-fabric/offlineskins-1.21.5-v1-fabric.jar";
      hash = "sha256-WOyALK5DdL9mGuc1tlVvM+8N8LUvtQNpXRaEgvGS54k=";
    };

    offlineSkins = pkgs.fetchurl {
      url = "https://github.com/FabricMC/fabric/releases/download/0.128.2%2B1.21.5/fabric-api-0.128.2+1.21.5.jar";
      hash = "sha256-qC/QCCcgbpEZNu0eDOrsbrVdBhyl08XWPH8AMUJtKa4=";
    };
  };
in
  pkgs.stdenv.mkDerivation {
    name = name;
    pname = name;

    srcs = [fabricServer] ++ builtins.attrValues mods;
    dontUnpack = true;

    nativeBuildInputs = with pkgs; [ makeWrapper ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/minecraft
      install -Dm644 ${fabricServer} $out/lib/minecraft/minecraft-server.jar

      mkdir -p $out/lib/minecraft/mods
      ${
        pkgs.lib.pipe mods [ 
          (builtins.mapAttrs (name: mod: "install -Dm644 ${mod} $out/lib/minecraft/mods/${name}.jar"))
          (builtins.attrValues)
          (pkgs.lib.concatStringsSep "\n")
        ]
      }

      makeWrapper ${pkgs.lib.getExe pkgs.jre_headless} $out/bin/minecraft-server \
        --append-flags "-jar $out/lib/minecraft/minecraft-server.jar nogui" \
        ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.udev ]}"}

      runHook postInstall
    '';
  }
