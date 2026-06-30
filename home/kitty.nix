{ ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      touch_scroll_multiplier = "10.0";
      scrollback_lines = 100000;
    };
    keybindings = {
      "page_up" = "scroll_page_up";
      "page_down" = "scroll_page_down";
      "ctrl+up" = "scroll_line_up";
      "ctrl+down" = "scroll_line_down";
    };
  };
}
