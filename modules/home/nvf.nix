{ config, pkgs, lib, ... }:

{
  # Neovim via nvf — https://github.com/NotAShelf/nvf
  #
  # ── Stylix + nvf conflict notes ────────────────────────────────────────────
  # stylix.targets.nvf (enabled at the bottom) sets:
  #   • vim.theme.*              — colorscheme (base16 via mini.base16)
  #   • vim.statusline.lualine.theme — set to "base16"
  # Our config must NOT set either of those or nix evaluation fails with
  # "conflicting definition values". They are intentionally absent here.
  # To change the colorscheme, change stylix.base16Scheme in configuration.nix.

  programs.nvf = {
    enable = true;

    settings.vim = {
      # ── Editor options ────────────────────────────────────────────────────
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

      # ── Theme — owned by stylix ───────────────────────────────────────────
      # Do NOT set vim.theme here — stylix.targets.nvf handles it.
      # Setting it here AND having stylix enabled = "conflicting definition values".

      # ── Keymaps ───────────────────────────────────────────────────────────
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

      # ── LSP ───────────────────────────────────────────────────────────────
      lsp = {
        enable               = true;
        formatOnSave         = false;
        lspkind.enable       = false;
        lightbulb.enable     = false;
        lspsaga.enable       = false;
        trouble.enable       = false;
        nvim-docs-view.enable = false;
      };

      # ── Languages ─────────────────────────────────────────────────────────
      languages = {
        enableLSP        = true;
        enableTreesitter = true;

        clang = {
          enable            = true;
          lsp.enable        = true;
          treesitter.enable = true;
        };

        lua = {
          enable            = true;
          lsp.enable        = true;
          treesitter.enable = true;
        };

        nix = {
          enable            = true;
          lsp.enable        = false;
          treesitter.enable = true;
        };

        julia = {
          enable            = true;
          lsp.enable        = false;
          treesitter.enable = true;
        };

        # Python
        python = {
          enable            = true;
          lsp.enable        = true;
          treesitter.enable = true;
        };

        # Rust
        rust = {
          enable            = true;
          lsp.enable        = true;
          treesitter.enable = true;
        };

        # Bash / shell
        bash = {
          enable            = true;
          lsp.enable        = true;
          treesitter.enable = true;
        };
      };

      # ── Completion ────────────────────────────────────────────────────────
      autocomplete.nvim-cmp.enable = true;

      # ── UI plugins ────────────────────────────────────────────────────────
      telescope.enable = true;

      # Lualine theme — owned by stylix (stylix.targets.nvf sets it to "base16")
      # Do NOT set statusline.lualine.theme here.
      statusline.lualine = {
        enable = true;
        # theme is intentionally absent — stylix sets it
      };

      treesitter = {
        enable           = true;
        fold             = false;
        highlight.enable = true;
        indent.enable    = true;
      };

      filetree.neo-tree.enable = true;

      # ── Yazi integration ──────────────────────────────────────────────────
      extraPlugins = {
        yazi-nvim = {
          package = pkgs.vimPlugins.yazi-nvim;
          setup = ''
            require("yazi").setup({
              open_for_directories = false,
              keymaps = { show_help = "<f1>" },
            })
          '';
        };
      };
    };
  };

  # ── Stylix target for nvf ─────────────────────────────────────────────────
  # Enables the base16 colorscheme and sets lualine's theme to match.
  # This is what would conflict if we also set vim.theme or lualine.theme above.
  stylix.targets.nvf.enable = true;
}
