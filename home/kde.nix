{ config, pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;
    };
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark
    Name=Breeze Dark
    shadeSortColumn=true
    TerminalApplication=kitty

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    widgetStyle=Breeze

    [Colors:Button]
    BackgroundAlternate=39,43,53
    BackgroundNormal=49,54,59
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=61,174,233
    ForegroundInactive=161,169,177
    ForegroundLink=29,153,243
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=239,240,241
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Selection]
    BackgroundAlternate=29,153,243
    BackgroundNormal=61,174,233
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=252,252,252
    ForegroundInactive=161,169,177
    ForegroundLink=253,188,75
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=239,240,241
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Tooltip]
    BackgroundAlternate=49,54,59
    BackgroundNormal=49,54,59
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=61,174,233
    ForegroundInactive=161,169,177
    ForegroundLink=29,153,243
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=239,240,241
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:View]
    BackgroundAlternate=35,38,41
    BackgroundNormal=27,30,32
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=61,174,233
    ForegroundInactive=161,169,177
    ForegroundLink=29,153,243
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=239,240,241
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [Colors:Window]
    BackgroundAlternate=49,54,59
    BackgroundNormal=49,54,59
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundActive=61,174,233
    ForegroundInactive=161,169,177
    ForegroundLink=29,153,243
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundNormal=239,240,241
    ForegroundPositive=39,174,96
    ForegroundVisited=155,89,182

    [WM]
    activeBackground=49,54,59
    activeForeground=239,240,241
    inactiveBackground=42,46,50
    inactiveForeground=161,169,177
  '';
}
