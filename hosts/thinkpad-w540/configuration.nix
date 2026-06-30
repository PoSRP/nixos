{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/btrfs-layout.nix
    ../../modules/desktop.nix
    ../../modules/nfs-shares.nix
  ];

  networking.hostName = "thinkpad-w540";

  swapDevices = [ { device = "/swap/swapfile"; size = 4096; } ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
