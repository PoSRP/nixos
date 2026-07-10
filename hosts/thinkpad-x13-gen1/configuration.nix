{ config, pkgs, lib, username, ... }:

let
  hyprDir = ".config/hypr";
in

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/btrfs-layout.nix
    ../../modules/desktop.nix
    ../../modules/nfs-shares.nix
  ];

  networking.hostName = "thinkpad-x13-gen1";

  swapDevices = [ { device = "/swap/swapfile"; size = 32768; } ];

  hardware.enableRedistributableFirmware = true;

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  services.upower = {
    enable = true;
    percentageLow = 30;
    percentageCritical = 20;
    percentageAction = 10;
    criticalPowerAction = "PowerOff";
  };

  home-manager.users.${username} = {
    home.file."${hyprDir}/battery-watcher.sh" = {
      source = ./battery-watcher.sh;
      executable = true;
    };
    home.file."${hyprDir}/battery-critical-alert.sh" = {
      source = ./battery-critical-alert.sh;
      executable = true;
    };
  };

  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "${config.services.tlp.package}/bin/tlp fullcharge BAT0";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.stateVersion = "25.11";
}
