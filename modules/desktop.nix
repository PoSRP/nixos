{ config, pkgs, lib, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      # Qt6 runtime deps for pip-installed PyQt6 in venvs
      libGL
      libxkbcommon
      fontconfig
      freetype
      dbus
      glib
      wayland
      xorg.libX11
      xorg.libxcb
      xorg.xcbutil
      xorg.xcbutilcursor
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  services.resolved = {
    enable = true;
    domains = [ "~homelab.local" ];
    fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
    extraConfig = ''
      DNS=192.168.1.207
    '';
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = username;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "where_is_my_sddm_theme";
    extraPackages = [ pkgs.kdePackages.qt5compat ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;

  security.polkit.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.ssh.startAgent = true;

  services.udev.packages = [ pkgs.stlink ];

  services.vnstat.enable = true;

  services.fwupd.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ epson-escpr gutenprint ];
  services.printing.cups-pdf.enable = true;
  services.printing.cups-pdf.instances.pdf.settings.Out = "\${HOME}/cups-pdf";
  hardware.printers.ensureDefaultPrinter = "pdf";

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.hyprland.default = [ "hyprland" "gtk" ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.groups.${username} = { gid = 1000; };

  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    group = username;
    extraGroups = [ "wheel" "networkmanager" "users" "docker" "libvirtd" "dialout" ];
    initialPassword = "default";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.shellAliases = {
    sxiv = "nsxiv";
  };

  environment.systemPackages = with pkgs; [
    anki
    audacity
    baobab
    blueman
    bmon
    bottles
    brightnessctl
    boost188
    btop
    curl
    darktable
    discord
    docker-compose
    drawio
    dropbox
    ffmpeg
    freecad
    gcc15
    gh
    gimp
    git
    gsimplecal
    git-crypt
    hardinfo2
    htop
    hyprpaper
    hyprshot
    inetutils
    jellyfin-media-player
    jq
    kdePackages.ark
    kdePackages.breeze
    kdePackages.isoimagewriter
    kdePackages.plasma-integration
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler
    keepassxc
    kicad
    kid3
    kitty
    krita
    libreoffice
    lm_sensors
    mako
    mate.atril
    meld
    micro
    mpv
    neofetch
    nicotine-plus
    nsxiv
    orca-slicer
    pavucontrol
    pulseaudio
    pinta
    playerctl
    qalculate-gtk
    bemenu
    libnotify
    rofi
    rpi-imager
    shellcheck
    spotify
    stm32cubemx
    sublime-merge
    system-config-printer
    (texlive.combine {
      inherit (texlive)
        scheme-medium
        enumitem
        lipsum
        fontawesome5
        fontaxes
        libertinus
        libertinus-fonts
        libertinus-type1;
    })
    texstudio
    thunderbird
    transmission_4-gtk
    usbutils
    nfs-utils
    rsync
    gnupg
    waybar
    wget
    where-is-my-sddm-theme
    tree
    python3
    python3Packages.tkinter
    clang-tools
    cmake
    gnumake
    ninja
    pre-commit
    claude-code
    minicom
    bmaptool
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    komika-fonts
    google-fonts
  ];

  programs.dconf.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
