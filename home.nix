{ config, pkgs, inputs, ... }:

{
  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep fd fzf bat eza
  ];

  programs.home-manager.enable = true;

  # Git
  programs.git = {
    enable = true;
    userName = "svea";
    userEmail = "svea@leavenworth";
  };

  # Fish shell configuration
  programs.fish = {
    enable = true;
    
    shellAliases = {
      # Nix shortcuts
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#leavenworth";
      update = "cd /etc/nixos && nix flake update";
      
      # Better commands
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      cat = "bat";
    };
    
    shellInit = ''
      # Disable greeting
      set fish_greeting
    '';
  };

  # Neovim via nixvim
  programs.nixvim = {
    enable = true;
    
    # Basic options
    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
    };

    # Minimal colorscheme
    colorschemes.base16 = {
      enable = true;
      colorscheme = "default-dark";
    };

    # Language support - syntax highlighting
    plugins = {
      treesitter = {
        enable = true;
        nixGrammars = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          lua
          python
          rust
          c
          nix
          bash
          julia
        ];
      };

      # LSP support (basic)
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;  # Nix
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          lua-ls.enable = true;
          pyright.enable = true;
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
      };
    };

    # Basic keymaps
    globals.mapleader = " ";
  };
}
