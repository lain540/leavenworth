{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/desktop.nix
  ];

  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
  ];

  programs.home-manager.enable = true;
  
  # nnn file manager
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    
    # nnn plugins and configuration
    extraPackages = with pkgs; [ ffmpeg mediainfo ];
    
    plugins = {
      src = "${pkgs.nnn}/share/plugins";
      mappings = {
        e = "!nvim \"$nnn\"*";
      };
    };
  };
  
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
        key = "<leader>n";
        action = "<cmd>NnnPicker<CR>";
        options = {
          desc = "Open nnn file picker";
        };
      }
    ];

    plugins = {
      lsp = {
        enable = true;
        servers = {
          lua-ls.enable = true;
          nixd.enable = true;
          # C/C++ language server
          clangd.enable = true;
          # Julia language server
          julials.enable = true;
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
    };
    
    # nnn.vim plugin - simpler integration
    extraPlugins = with pkgs.vimPlugins; [
      nnn-vim
    ];
    
    extraConfigLua = ''
      -- nnn.vim configuration
      vim.g.nnn_command = 'nnn -e'
      vim.g.nnn_layout = { window = { width = 0.9, height = 0.6, highlight = 'Debug' } }
      vim.g.nnn_action = {
        ['<c-t>'] = 'tab split',
        ['<c-x>'] = 'split',
        ['<c-v>'] = 'vsplit',
      }
    '';
  };

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
