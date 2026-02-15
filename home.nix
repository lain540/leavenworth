{ config, pkgs, ... }:

{
  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep fd fzf
  ];

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "svea";
    userEmail = "svea@leavenworth";
  };

  programs.fish.enable = true;
}
