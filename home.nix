{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/desktop.nix
    ./modules/home/applications.nix
    ./modules/home/shell.nix
    ./modules/home/nvf.nix
  ];

  home.username      = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;

  # ── Git ───────────────────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    userName  = "lain540";
    userEmail = "lain540@users.noreply.github.com";
    settings  = { init.defaultBranch = "main"; pull.rebase = false; };
  };

  # ── XDG ───────────────────────────────────────────────────────────────────────
  xdg.userDirs = { enable = true; createDirectories = true; };

  # ── Yazi ──────────────────────────────────────────────────────────────────────
  programs.yazi = {
    enable               = true;
    enableZshIntegration = true;
    shellWrapperName     = "y";
    settings = {
      manager = { show_hidden = false; sort_by = "natural"; sort_dir_first = true; };
      preview = { image_protocol = "sixel"; max_width = 600; max_height = 900; };
    };
  };

  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # CLI utilities
    ripgrep fd fzf

    # Yazi dependencies
    ffmpegthumbnailer  # video thumbnails
    unar               # archive extraction (RAR etc.)
    jq                 # JSON previews
    poppler-utils      # PDF previews
    imagemagick        # image previews
    file               # file type detection
  ];
}
