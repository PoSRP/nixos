{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "qemu-desktop";

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };

  system.stateVersion = "25.11";
}
