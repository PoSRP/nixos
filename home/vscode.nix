{ config, pkgs, ... }:

{
  programs.vscode = {
    enable  = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = {
        "editor.fontFamily"                        = "'JetBrainsMono Nerd Font Mono', 'Noto Color Emoji', monospace";
        "editor.fontSize"                          = 13;
        "editor.minimap.enabled"                   = false;
        "editor.formatOnSave"                      = true;
        "editor.defaultFormatter"                  = "xaver.clang-format";
        "extensions.ignoreRecommendations"         = true;
        "update.mode"                              = "none";
      };

      extensions = with pkgs.vscode-extensions; [
        # C/C++ - pack includes cpptools + themes + cmake
        ms-vscode.cpptools
        ms-vscode.cpptools-extension-pack
        xaver.clang-format

        # Build systems
        ms-vscode.cmake-tools
        twxs.cmake

        # Python (not Pylance)
        ms-python.python

        # Other languages / formats
        mechatroner.rainbow-csv
        tomoki1207.pdf

        # Remote and tools
        ms-vscode-remote.remote-ssh
        github.vscode-github-actions
      ];
    };
  };
}
