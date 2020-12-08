{ config, pkgs, ... }:

let
  userName = "evenbrenden";
  hostName = "naxos";
in
{
  imports = [
    ../common-configuration.nix
    ./x1c7-audio-hacks.nix
    ./hardware-configuration.nix
  ];

  # Steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.opengl.driSupport32Bit = true;

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "vboxusers" ];
  };

  services.xserver = {
    dpi = 144;
    displayManager.autoLogin = {
      enable = true;
      user = "${userName}";
    };
  };

  virtualisation.virtualbox.host = {
    enableExtensionPack = true;
    enable = true;
  };

  networking.hostName = "${hostName}";
}
