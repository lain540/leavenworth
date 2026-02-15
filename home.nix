{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/desktop.nix
  ];

  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];

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

    plugins = {
      lsp = {
        enable = true;
        servers = {
          lua-ls.enable = true;
          nixd.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          clangd.enable = true;
          pyright.enable = true;
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          lua nix rust c python bash
        ];
        folding = false;
        nixvimInjections = true;
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
    };
  };

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
