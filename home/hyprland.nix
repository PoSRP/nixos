{ config, pkgs, ... }:

{
  home.file = {
    ".config/hypr/hyprland.lua".source = ./hyprland/hyprland.lua;
    ".config/hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;
    ".config/hypr/hyprpaper.conf".source = ./hyprland/hyprpaper.conf;
    ".config/hypr/hyprpaper-rotator.sh" = {
      source = ./hyprland/hyprpaper-rotator.sh;
      executable = true;
    };
    ".config/hypr/hyprpaper-private-toggle.sh" = {
      source = ./hyprland/hyprpaper-private-toggle.sh;
      executable = true;
    };
    ".config/hypr/lock-session.sh" = {
      source = ./hyprland/lock-session.sh;
      executable = true;
    };
  };
}
