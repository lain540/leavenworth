{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/desktop.nix
    ./modules/home/applications.nix
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

  # Neovim via nixvim
  programs.nixvim = {
    enable = true;
    
    colorschemes.base16 = {
      enable = true;
      colorscheme = "default-dark";
    };

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      hlsearch = true;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      updatetime = 50;
    };

    globals.mapleader = " ";

    keymaps = [
      {
        key = "<leader>e";
        action = "<cmd>Yazi<CR>";
        options = {
          desc = "Open yazi file manager";
        };
      }
    ];

    plugins = {
      lsp = {
        enable = true;
        servers = {
          lua-ls.enable = true;
          clangd.enable = true;  # C/C++
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          cpp lua nix julia
        ];
        folding = false;
        nixvimInjections = true;
        # Prevent log file errors
        logLevel = "off";
      };

      neo-tree.enable = true;
      telescope.enable = true;
      
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      lualine.enable = true;
      
      # yazi file manager integration
      yazi.enable = true;
    };
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

    # Extra packages needed for previews and archive support
    package = pkgs.yazi;

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

  # Packages required by yazi for full functionality
  home.packages = with pkgs; [
    ripgrep
    fd
    fzf

    # Yazi dependencies
    ffmpegthumbnailer  # Video thumbnails
    unar               # RAR and other archive extraction
    jq                 # JSON previews
    poppler_utils      # PDF previews
    imagemagick        # Image previews
    file               # File type detection
  ];
}
