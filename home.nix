{ config, pkgs, inputs, ... }:

let
  secrets = if builtins.pathExists /etc/nixos/secrets.nix
            then import /etc/nixos/secrets.nix
            else {
              git = {
                userName = "svea";
                userEmail = "svea@leavenworth";
              };
            };
in
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
    userName = secrets.git.userName;
    userEmail = secrets.git.userEmail;
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

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
}
