{ config, pkgs, inputs, ... }:

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

  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#leavenworth";
      update = "cd /etc/nixos && sudo ./rebuild.sh";
    };
    shellInit = ''
      # Disable greeting
      set fish_greeting
    '';
  };

  # nixvim - Neovim configuration
  programs.nixvim = {
    enable = true;
    
    # Color scheme
    colorschemes.base16 = {
      enable = true;
      colorscheme = "default-dark";
    };

    # General settings
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

    # Keymaps
    globals.mapleader = " ";

    # LSP for languages
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
          clangd.enable = true;       # C
          pyright.enable = true;       # Python
        };
      };

      # Treesitter for syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          lua
          nix
          rust
          c
          python
          bash
        ];
      };

      # File explorer
      neo-tree.enable = true;

      # Fuzzy finder
      telescope.enable = true;

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      # Status line
      lualine.enable = true;
    };
  };
}
