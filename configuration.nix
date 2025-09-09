{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  nix.settings = {
    sandbox = false;
    experimental-features = [ "nix-command" "flakes" ];
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
  ];

  services.fabric-server = {
    enable = true;
    openFirewall = true;
    eula = true;
    serverProperties = {
      "enable-rcon" = true;
      "rcon.port" = 25575;
      # I don't care, port is blocked on network level.
      "rcon.password" = "password";
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "yes";
    };
  };

  system.stateVersion = "24.11";
}
