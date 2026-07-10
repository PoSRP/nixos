{ config, pkgs, ... }:

{
  home.file = {
    ".config/waybar/config".source = ./waybar/config;
    ".config/waybar/style.css".source = ./waybar/style.css;
    ".config/waybar/disk.sh" = {
      source = ./waybar/disk.sh;
      executable = true;
    };
    ".config/waybar/temp.sh" = {
      source = ./waybar/temp.sh;
      executable = true;
    };
    ".config/waybar/battery.sh" = {
      source = ./waybar/battery.sh;
      executable = true;
    };
    ".config/waybar/battery-menu.sh" = {
      source = ./waybar/battery-menu.sh;
      executable = true;
    };
    ".config/waybar/network.sh" = {
      source = ./waybar/network.sh;
      executable = true;
    };
    ".config/waybar/wallpaper-mode.sh" = {
      source = ./waybar/wallpaper-mode.sh;
      executable = true;
    };
  };
}
