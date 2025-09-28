{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  nix.settings = {
    sandbox = false;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  security.pam.services.sshd.allowNullPassword = true;

  time.timeZone = "Europe/Warsaw";

  environment.systemPackages = with pkgs; [
    neovim
    neofetch
    tree
    gotop
  ];

  nixpkgs.config.allowUnfree = true;

  # services.fabric-server = {
  #   enable = true;
  #   openFirewall = true;
  #   eula = true;
  #   serverProperties = {
  #     "enable-rcon" = true;
  #     "rcon.port" = 25575;
  #     # I don't care, port is blocked on network level.
  #     "rcon.password" = "password";
  #   };
  # };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      PermitEmptyPasswords = "yes";
    };
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.fabric = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_7;

      serverProperties = {
        difficulty = "hard";
        enforce-whitelist = false;
        gamemode = "survival";
        level-seed = "3341418238313829147";
        max-players = 1939;
        motd = "minekampf";
        online-mode = true;
        view-distance = 20;
        white-list = false;
      };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/JntuF9Ul/fabric-api-0.129.0%2B1.21.7.jar";
              sha512 = "sha512-Q79q8UWmtFBQOm1+fsmjSRK9FJSWm12IYQZ/D4Rs9xCAVBX7D7yTya6fUWTUXHZJNC+EtPNFUrKr3Ykv07mDjg==";
            };
            Lithium = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/77EtzYFA/lithium-fabric-0.18.0%2Bmc1.21.7.jar";
              sha512 = "sha512-r69t2vDLriBQ1yXv1DjEyYFB1zimN/DwWNy6/wd++Fr4AeLcoTjOn3+Lo6Fp3GrxyfVnNrJVxuoTNj+KG+js2w==";
            };
            EasyAuth = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/aZj58GfX/versions/5PoSvmj4/easyauth-mc1.21.6-3.3.6.jar";
              sha512 = "sha512-eS/5JasqtktHRHGzSlGS+eX4QzMc7r/fUobkbSI1wDuEo0VgwPT/cjpq+0dblUuGRwJCfZH+XWJn95eaWdQfQg==";
            };
            EasyWhitelist = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/LODybUe5/versions/9OoxSFQz/easywhitelist-1.1.0.jar";
              hash = "sha256-gon45yHrNvgbwTt7bK1N9r0wpR91j5ynAlF+YQzwzQA=";
            };
            Vanish = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/UL4bJFDY/versions/gigHDcN5/vanish-1.6.0%2B1.21.8.jar";
              sha512 = "sha512-s2uRoOZZd8I3OU1YwQ5dtfVhbBeX1xZOVjnYqTjPzOwBeZsvD1uXsE+J7qGP7/I9ezyDMKgPbq6Pa72AphJiWw==";
            };
            DistantHorizons = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/2mY04ehi/DistantHorizons-2.3.3-b-1.21.7-fabric-neoforge.jar";
              sha512 = "sha512-X41OVk9l3L5eA5r4YF2k34qO3MIhikaq2CeqqNHohIrbMCZyc19XlxW+HEgJVt1t11SKK/+brMTw7wWS7s6yOA==";
            };
            DiscordJustSync = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/sTKgOp3k/versions/WyYDWnZe/DiscordJustSync-1.16.2.jar";
              hash = "sha256-cz9gaTd10zCyB+YQExnGbnX5ow+v4dxbnxqEN7EJRGU=";
            };
            # localMod = pkgs.runCommand "localMod.jar" { } ''
            #   ln -s ${pkgs.localMod}/lib/localMod.jar $out
            # '';
          }
        );
      };

      files = {
        "config/discord-js/discord-justsync.toml" = {
          value = {
            # Discord bot token, required to connect to Discord (get from Discord Developer Portal)
            botToken = "";
            # Discord channel ID to sync with Minecraft chat (required - right-click channel and copy ID)
            serverChatChannel = "1417266960101670973";
            # Use Discord webhooks for chat messages with player avatars and usernames
            useWebHooks = false;

            linking = {
              # Require players to link their Minecraft account to a Discord account before joining
              enableLinking = true;
              # Automatically unlink players when they leave the Discord server
              unlinkOnLeave = true;
              # Log account linking and unlinking events to a Discord channel
              logLinking = false;
              # Discord channel ID for logging linking events (only used if logLinking is true)
              linkingLogChannel = "";
              # Discord roles that players must have to join the Minecraft server (list of role IDs)
              requiredRoles = [ "496425145401868292" ];
              # "Minimum number of roles from requiredRoles list that players must have
              # "-1 means all roles are required, 1 means at least one role is required"})
              requiredRolesCount = -1;
              # Discord roles to automatically assign when players join Minecraft
              joinRoles = [ "1419460206752038982" ];
              # Automatically set Discord nickname to match Minecraft username when players join
              renameOnJoin = false;
              # Prevent Discord users with active timeouts from joining Minecraft
              disallowTimeoutMembersToJoin = true;
              # How long (in minutes) a linking code remains valid before expiring
              linkCodeExpireMinutes = 10;
              # "Maximum alternate accounts that can be linked to one Discord account
              # "Example: maxAlts=1 allows 1 main account + 1 alt account per Discord user"})
              maxAlts = 0;
            };
          };
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
