{ config, pkgs, ... }:

{
  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;
  home.file.".config/nmtui/colors".source = ./zsh/nmtui-colors;

  home.sessionVariables.NEWT_COLORS_FILE = "${config.home.homeDirectory}/.config/nmtui/colors";

  programs.git = {
    enable = true;
    signing.signByDefault = true;
    includes = [{ path = "~/.config/git/local"; }];
    settings = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zhistory";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      rcp = "rsync -rlp --info=progress2";
      df = "df -h";
      free = "free -m";
      l = "ls -lh";
      la = "ls -lah";
      ls = "ls --color=auto";
      cdw = "cd ~/workspace";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      source ${./zsh/init.zsh}
      source ${./zsh/functions.zsh}
    '';
  };
}
