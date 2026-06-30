{ ... }:

{
  xdg.configFile."mako/config".text = ''
    default-timeout=3000

    [app-name=Spotify]
    invisible=1
  '';
}
