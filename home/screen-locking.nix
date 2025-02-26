{ pkgs, ... }:

{
  services = {
    # https://github.com/nix-community/home-manager/pull/6534
    screen-locker = {
      enable = true;
      # https://github.com/google/xsecurelock/issues/186
      # https://github.com/google/xsecurelock/issues/182
      lockCmd = let refresh-display = "${pkgs.autorandr}/bin/autorandr --force --change clone-largest";
      in ''
        ${pkgs.lib.getExe pkgs.bash} -c '\
          XSECURELOCK_DISCARD_FIRST_KEYPRESS=0 \
          XSECURELOCK_KEY_XF86Display_COMMAND=\'${refresh-display}\' \
          XSECURELOCK_KEY_F7_COMMAND=\'${refresh-display}\' \
          ${pkgs.xsecurelock}/bin/xsecurelock'
      '';
      xss-lock.extraOptions = [ "--transfer-sleep-lock" ];
    };
    # https://github.com/nix-community/home-manager/pull/6533
    # Temporarily disable with: systemctl --user stop xidlehook.service
    xidlehook = {
      enable = true;
      timers = [{
        command = "${pkgs.systemd}/bin/loginctl lock-session $XDG_SESSION_ID";
        delay = 15 * 60;
      }];
      not-when-fullscreen = true;
    };
  };
  systemd.user.services.disable-xset-s-and-dpms = {
    Unit = {
      Description = "Disable X Screen Saver and DPMS";
      After = [ "xss-lock.service" ];
    };
    Service = let xset = "${pkgs.lib.getExe pkgs.xorg.xset}";
    in {
      Type = "oneshot";
      ExecStart = "${pkgs.lib.getExe pkgs.bash} -c '${xset} s off && ${xset} -dpms'";
    };
    Install = { WantedBy = [ "xss-lock.service" ]; };
  };
}
