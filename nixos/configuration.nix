{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p1";
        preLVM = true;
        allowDiscards = true;
      };
    };
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 120;
      };
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "alsa-hda-realtek-fix-1";
        patch = ./0001-ALSA-hda-realtek-Fix-Lenovo-Thinkpad-X1-Carbon-7th-q.patch;
      }
      {
        name = "alsa-hda-realtek-fix-2";
        patch = ./0002-ALSA-hda-realtek-Fix-Lenovo-Thinkpad-X1-Carbon-7th-q.patch;
      }
      {
        name = "alsa-hda-realtek-fix-3";
        patch = ./0003-Rename-some-controls-for-the-benefit-of-pulseaudio.patch;
      }
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking = {
    hostName = "naxos";
    networkmanager.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true; # Explicit PulseAudio support in applications

  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
  nixpkgs.overlays = [
    (import ../overlays/jetbrains_old.nix)
    (import ../overlays/pulseaudio.nix)
    (import ../overlays/sof-firmware.nix)
  ];

  nixpkgs.config = {
    allowUnfree = true;
    chromium.enableWideVine = true;
  };

  environment = {
    systemPackages = with pkgs; [
      abcde
      alsaTools
      arandr
      autorandr
      brightnessctl
      cabal-install
      chromium
      curl
      dbeaver
      dos2unix
      dunst
      firefox
      gimp
      git
      gparted
      hsetroot
      irssi
      jetbrains.rider
      networkmanagerapplet
      libnotify
      libsForQt5.vlc
      linuxConsoleTools
      nomacs
      playerctl
      postman
      python3
      python37Packages.virtualenv
      rclone
      remmina
      sakura
      shellcheck
      slack
      spotify
      dotnet-sdk_3
      jotta-cli
      teams
      unzip
      veracrypt
      vscode
      xorg.xdpyinfo
    ];
  };

  virtualisation.virtualbox.host = {
    enableExtensionPack = true;
    enable = true;
  };

  programs.ssh.startAgent = true;

  nix.gc.automatic = true;
  nix.gc.dates = "04:00";

  time.timeZone = "Europe/Amsterdam";

  users.users.evenbrenden = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "vboxusers" ];
  };

  services = {
    dbus.socketActivated = true;
    openssh.enable = false;
    picom.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      dpi = 144;
      libinput = {
        enable = true;
        tapping = true;
      };
      displayManager = {
        defaultSession = "none+i3";
        lightdm = {
          autoLogin.enable = true;
          autoLogin.user = "evenbrenden";
          background = "#000000";
          greeters.gtk.indicators = [ "~host" "~spacer" "~session" "~language" "~clock" "~power" ];
        };
        # Because xsetroot does not work with Picom
        sessionCommands = ''
            hsetroot -solid #000000
        '';
      };
      windowManager.i3.enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
    };
  };

  system.stateVersion = "20.03";
}
