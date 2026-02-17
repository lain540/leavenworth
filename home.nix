{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/desktop.nix
    ./modules/home/applications.nix
    ./modules/home/nvf.nix
  ];

  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "lain540";
    userEmail = "lain540@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#leavenworth";
      update = "cd /etc/nixos && sudo ./scripts/rebuild.sh";
    };
    shellInit = ''
      set fish_greeting
    '';
  };

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Yazi file manager - with RAR support and image preview in foot
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };

      preview = {
        # Image preview via sixel protocol (supported by foot)
        image_protocol = "sixel";
        max_width = 600;
        max_height = 900;
      };
    };
  };

  # Packages
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf

    # Yazi dependencies
    ffmpegthumbnailer  # Video thumbnails
    unar               # RAR and other archive extraction
    jq                 # JSON previews
    poppler-utils      # PDF previews
    imagemagick        # Image previews
    file               # File type detection
  ];
}

