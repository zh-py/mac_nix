{ inputs, ... }:
{
  imports = [
    inputs.hyprshell.homeModules.hyprshell
  ];
  programs.hyprshell = {
    enable = true;
    systemd.args = "-v";
    settings = {
      windows = {
        overview = {
          #key = "super_l";
          key = "tab";
          modifier = "alt";
          launcher = {
            max_items = 5;
            plugins.websearch = {
              enable = true;
              engines = [
                {
                  name = "DuckDuckGo";
                  url = "https://duckduckgo.com/?q=%s";
                  key = "d";
                }
              ];
            };
          };
        };
        switch = {
          modifier = "super";
        };
      };
    };
  };
}
