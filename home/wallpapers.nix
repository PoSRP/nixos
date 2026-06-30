{ config, pkgs, lib, ... }:

{
  # Copy (don't symlink) default-wallpaper.png only when ~/.wallpapers/ is empty.
  # This way a fresh install gets a working wallpaper before post-install runs,
  # and once post-install syncs the real set and removes the default, subsequent
  # HM activations won't recreate it.
  home.activation.installDefaultWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.wallpapers"
    if [ -z "$(find "$HOME/.wallpapers" -mindepth 1 -maxdepth 1 -type f 2>/dev/null)" ]; then
      install -m 644 ${./default-wallpaper.png} "$HOME/.wallpapers/default-wallpaper.png"
    fi
  '';
}
