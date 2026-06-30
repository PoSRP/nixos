{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "i8042" "atkbd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/root";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
