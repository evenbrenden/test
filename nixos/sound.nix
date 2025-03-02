{ pkgs, ... }:

{
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudio.override { bluetoothSupport = true; };
    };
  };
  services.pipewire.enable = false;
}
