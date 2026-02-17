{ config, pkgs, lib, ... }:

{
  # Neovim via nvf - https://github.com/NotAShelf/nvf
  programs.nvf = {
    enable = true;

    settings.vim = {
      # ── Editor options via raw lua ────────────────────────────────────
      # luaConfigRC values are plain strings in nvf, not DAG entries
      luaConfigRC.options = ''
        vim.opt.number         = true
        vim.opt.relativenumber = true
        vim.opt.tabstop        = 2
        vim.opt.shiftwidth     = 2
        vim.opt.expandtab      = true
        vim.opt.smartindent    = true
        vim.opt.wrap           = false
        vim.opt.swapfile       = false
        vim.opt.backup         = false
        vim.opt.hlsearch       = true
        vim.opt.incsearch      = true
        vim.opt.termguicolors  = true
        vim.opt.scrolloff      = 8
        vim.opt.updatetime     = 50
        vim.g.mapleader        = " "
        vim.g.maplocalleader   = " "
      '';

      # ── Theme - base16-default-dark matching foot/waybar ─────────────
      # base16 theme requires all 16 colors to be explicitly provided
      # https://nvf.notashelf.dev/options.html#option-vim-theme-enable
      theme = {
        enable      = true;
        name        = "base16";
        style       = "dark";
        transparent = false;

        # Same hex values used in foot terminal and waybar
        base16-colors = {
          base00 = "181818"; # background
          base01 = "282828"; # lighter background
          base02 = "383838"; # selection background
          base03 = "585858"; # comments / inactive
          base04 = "b8b8b8"; # dark foreground
          base05 = "d8d8d8"; # foreground
          base06 = "e8e8e8"; # light foreground
          base07 = "f8f8f8"; # light background
          base08 = "ab4642"; # red
          base09 = "dc9656"; # orange
          base0A = "f7ca88"; # yellow
          base0B = "a1b56c"; # green
          base0C = "86c1b9"; # cyan
          base0D = "7cafc2"; # blue
          base0E = "ba8baf"; # magenta
          base0F = "a16946"; # brown
        };
      };

      # ── Keymaps ───────────────────────────────────────────────────────
      maps.normal = {
        "<leader>e"  = { action = "<cmd>Yazi<CR>";                          desc = "Open yazi"; };
        "<leader>ff" = { action = "<cmd>Telescope find_files<CR>";          desc = "Find files"; };
        "<leader>fg" = { action = "<cmd>Telescope live_grep<CR>";           desc = "Live grep"; };
        "<leader>fb" = { action = "<cmd>Telescope buffers<CR>";             desc = "Buffers"; };
        "gd"         = { action = "<cmd>lua vim.lsp.buf.definition()<CR>";  desc = "Go to definition"; };
        "K"          = { action = "<cmd>lua vim.lsp.buf.hover()<CR>";       desc = "LSP hover"; };
        "<leader>rn" = { action = "<cmd>lua vim.lsp.buf.rename()<CR>";      desc = "LSP rename"; };
        "<leader>ca" = { action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; desc = "Code action"; };
      };

      # ── LSP ───────────────────────────────────────────────────────────
      lsp = {
        enable        = true;
        formatOnSave  = false;
        lspkind.enable        = false;
        lightbulb.enable      = false;
        lspsaga.enable        = false;
        trouble.enable        = false;
        nvim-docs-view.enable = false;
      };

      # ── Languages ─────────────────────────────────────────────────────
      languages = {
        enableLSP        = true;
        enableTreesitter = true;

        # C / C++
        clang = {
          enable             = true;
          lsp.enable         = true;
          treesitter.enable  = true;
        };

        # Lua
        lua = {
          enable             = true;
          lsp.enable         = true;
          treesitter.enable  = true;
        };

        # Nix - treesitter only
        nix = {
          enable             = true;
          lsp.enable         = false;
          treesitter.enable  = true;
        };

        # Julia - treesitter only
        julia = {
          enable             = true;
          lsp.enable         = false;
          treesitter.enable  = true;
        };
      };

      # ── Completion ────────────────────────────────────────────────────
      autocomplete.nvim-cmp.enable = true;

      # ── UI plugins ────────────────────────────────────────────────────
      telescope.enable = true;

      statusline.lualine = {
        enable = true;
        theme  = "auto";
      };

      treesitter = {
        enable           = true;
        fold             = false;
        highlight.enable = true;
        indent.enable    = true;
      };

      filetree.neo-tree = {
        enable = true;
      };

      # ── Yazi integration ─────────────────────────────────────────────
      # https://github.com/mikavilpas/yazi.nvim
      extraPlugins = {
        yazi-nvim = {
          package = pkgs.vimPlugins.yazi-nvim;
          setup = ''
            require("yazi").setup({
              open_for_directories = false,
              keymaps = {
                show_help = "<f1>",
              },
            })
          '';
        };
      };
    };
  };
}
