{ pkgs, username, ... }:

let
  rawThumbnailer = pkgs.writeShellApplication {
    name = "raw-thumbnailer";
    runtimeInputs = with pkgs; [ exiv2 coreutils ];
    text = ''
      in="$1"
      out="$2"
      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT
      base=$(basename "$in")
      ln -sf "$in" "$tmp/$base"
      ( cd "$tmp" && exiv2 -ep "$base" ) >/dev/null 2>&1 || exit 1
      largest=""
      largest_size=0
      for pv in "$tmp"/*-preview*.jpg; do
        [ -f "$pv" ] || continue
        s=$(stat -c%s "$pv")
        if [ "$s" -gt "$largest_size" ]; then
          largest_size=$s
          largest=$pv
        fi
      done
      [ -n "$largest" ] || exit 1
      cp "$largest" "$out"
    '';
  };
in
{
  xdg.configFile."Thunar/thunarrc".text = ''
    [Configuration]
    DefaultView=ThunarDetailsView
  '';

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///home/${username}/Downloads Downloads
    file:///home/${username}/Documents Documents
    file:///home/${username}/Pictures Pictures
    file:///home/${username}/workspace Workspace
    file:///mnt/files Files
    file:///mnt/music Music
    file:///mnt/images Images
    file:///mnt/videos Videos
  '';

  xdg.dataFile."thumbnailers/raw.thumbnailer".text = ''
    [Thumbnailer Entry]
    TryExec=${pkgs.exiv2}/bin/exiv2
    Exec=${rawThumbnailer}/bin/raw-thumbnailer %i %o
    MimeType=image/x-canon-cr2;image/x-canon-cr3;image/x-canon-crw;image/x-sony-arw;image/x-nikon-nef;image/x-adobe-dng;image/x-olympus-orf;image/x-panasonic-rw2;image/x-fuji-raf;
  '';
}
