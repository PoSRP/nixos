{ config, pkgs, username, ... }:

{
  imports = [
    ./firefox.nix
    ./hyprland.nix
    ./kitty.nix
    ./mako.nix
    ./thunar.nix
    ./vscode.nix
    ./waybar.nix
    ./wallpapers.nix
    ./shell.nix
    ./kde.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  home.file.".claude/settings.json".source = ./claude/settings.json;
  home.file.".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";

  programs.home-manager.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
