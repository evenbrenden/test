{ config, pkgs, sops-nix, ... }:

{
  # User
  home = {
    username = "evenbrenden";
    homeDirectory = "/home/${config.home.username}";
  };

  # Dotfiles
  home.file = {
    ".abcde.conf".source = ./dotfiles/abcde.conf;
    ".aider.conf.yml".source = ./dotfiles/aider.conf.yml;
    ".ghci".source = ./dotfiles/ghci;
    ".prettierrc".source = ./dotfiles/prettierrc;
    ".ssr/settings.conf".source = ./dotfiles/ssr.conf;
  };
  xdg = {
    configFile = {
      "autorandr/postswitch".source = ./dotfiles/autorandr-postswitch;
      "fourmolu.yaml".source = ./dotfiles/fourmolu.yaml;
      "kde.org/ghostwriter.conf".source = ./dotfiles/ghostwriter.conf;
      "parcellite/parcelliterc".source = ./dotfiles/parcelliterc;
      "snes9x/snes9x.conf".source = ./dotfiles/snes9x.conf;
      "VeraCrypt/Favorite Volumes.xml".source = ./dotfiles/veracrypt-favorite-volumes.xml;
    };
  };

  # Programs
  imports = [
    ./alacritty.nix
    ./bash.nix
    ./emote.nix
    ./git.nix
    ./i3/i3.nix
    ./mimeapps.nix
    ./screen-locking.nix
    sops-nix
    ./ssh.nix
    ./studio/studio.nix
    ./vi/vi.nix
    ./work.nix
  ];
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
    man.enable = false;
  };
  home.packages = with pkgs;
    let
      programming = [
        unstable.aider-chat
        docker-compose
        (import ./fmtall.nix { inherit pkgs; })
        ghc
        graphviz
        haskellPackages.cabal-fmt
        hurl
        mypy
        python3
        shellcheck
        virtualenv
      ];
      miscellaneous = [
        abcde
        age
        arandr
        audacity
        binutils # For strings (to make less print binary files)
        chromium
        curl
        unstable.discord
        dos2unix
        file
        firefox
        fff
        flac
        fzf
        ghostwriter
        gimp
        gparted
        irssi
        jq
        libheif
        libnotify
        libreoffice
        nomacs
        okular
        p7zip
        pandoc
        pavucontrol
        (import ./wallpaper/refresh-wallpaper.nix { inherit pkgs; })
        rclone
        unstable.signal-desktop
        simplescreenrecorder
        slack
        smartmontools
        snes9x-gtk
        sops
        transmission_4-gtk
        tree
        unstable.veracrypt
        vlc
        whatsapp-for-linux
        xclip
        xcolor
        (import ./x-www-browser.nix { inherit pkgs; })
      ];
    in programming ++ miscellaneous;

  # Services
  services = {
    dunst = {
      enable = true;
      configFile = ./dotfiles/dunstrc;
    };
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
        };
      };
    };
    # Ctrl+Alt+H
    parcellite = {
      enable = true;
      extraOptions = [ "--no-icon" ];
    };
  };
  systemd.user = {
    startServices = true;
    # https://github.com/nix-community/home-manager/issues/2064#issuecomment-887300055
    targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };

  # SOPS
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt"; # Need this or will silently fail
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      codeberg-org-private-key.path = "${config.home.homeDirectory}/.ssh/codeberg-org-private-key";
      github-com-private-key.path = "${config.home.homeDirectory}/.ssh/github-com-private-key";
    };
  };

  # Misc
  home.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;
}
