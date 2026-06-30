{ username, ... }:

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
}
