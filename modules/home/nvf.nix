{ config, pkgs, lib, ... }:

{
  # Neovim via nvf - https://github.com/NotAShelf/nvf
  programs.nvf = {
    enable = true;

    settings.vim = {
      # ── Basic options (via raw lua - safest approach) ─────────────────
      luaConfigRC.options = lib.nvim.dag.entryAnywhere ''
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

      # ── Colorscheme - base16-default-dark matching foot/waybar ────────
      luaConfigRC.colorscheme = lib.nvim.dag.entryAnywhere ''
        -- base16-default-dark palette (same values as foot terminal and waybar)
        local c = {
          base00 = "#181818", -- background
          base01 = "#282828", -- lighter background
          base02 = "#383838", -- selection background
          base03 = "#585858", -- comments / inactive
          base04 = "#b8b8b8", -- dark foreground
          base05 = "#d8d8d8", -- foreground
          base06 = "#e8e8e8", -- light foreground
          base07 = "#f8f8f8", -- light background
          base08 = "#ab4642", -- red
          base09 = "#dc9656", -- orange
          base0A = "#f7ca88", -- yellow
          base0B = "#a1b56c", -- green
          base0C = "#86c1b9", -- cyan
          base0D = "#7cafc2", -- blue
          base0E = "#ba8baf", -- magenta
          base0F = "#a16946", -- brown
        }

        vim.cmd("highlight clear")
        vim.cmd("syntax reset")
        vim.o.termguicolors = true
        vim.g.colors_name   = "base16-default-dark"

        local function hi(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        hi("Normal",                    { bg = c.base00, fg = c.base05 })
        hi("NormalFloat",               { bg = c.base01, fg = c.base05 })
        hi("NormalNC",                  { bg = c.base00, fg = c.base05 })
        hi("SignColumn",                { bg = c.base00, fg = c.base03 })
        hi("LineNr",                    { fg = c.base03 })
        hi("CursorLineNr",              { fg = c.base05, bold = true })
        hi("CursorLine",                { bg = c.base01 })
        hi("Comment",                   { fg = c.base03, italic = true })
        hi("Constant",                  { fg = c.base09 })
        hi("String",                    { fg = c.base0B })
        hi("Identifier",                { fg = c.base08 })
        hi("Function",                  { fg = c.base0D })
        hi("Statement",                 { fg = c.base0E })
        hi("Keyword",                   { fg = c.base0E })
        hi("Operator",                  { fg = c.base05 })
        hi("PreProc",                   { fg = c.base0A })
        hi("Type",                      { fg = c.base0A })
        hi("Special",                   { fg = c.base0C })
        hi("Error",                     { fg = c.base08 })
        hi("Todo",                      { fg = c.base0A, bold = true })
        hi("Visual",                    { bg = c.base02 })
        hi("Search",                    { bg = c.base0A, fg = c.base00 })
        hi("IncSearch",                 { bg = c.base09, fg = c.base00 })
        hi("MatchParen",                { bg = c.base03 })
        hi("Pmenu",                     { bg = c.base01, fg = c.base05 })
        hi("PmenuSel",                  { bg = c.base02, fg = c.base06 })
        hi("PmenuSbar",                 { bg = c.base01 })
        hi("PmenuThumb",                { bg = c.base03 })
        hi("StatusLine",                { bg = c.base01, fg = c.base04 })
        hi("StatusLineNC",              { bg = c.base01, fg = c.base03 })
        hi("WinSeparator",              { fg = c.base03 })
        hi("TabLine",                   { bg = c.base01, fg = c.base03 })
        hi("TabLineSel",                { bg = c.base02, fg = c.base05 })
        hi("TabLineFill",               { bg = c.base00 })
        hi("Directory",                 { fg = c.base0D })
        hi("DiagnosticError",           { fg = c.base08 })
        hi("DiagnosticWarn",            { fg = c.base0A })
        hi("DiagnosticInfo",            { fg = c.base0D })
        hi("DiagnosticHint",            { fg = c.base0C })
        hi("TelescopeNormal",           { bg = c.base00, fg = c.base05 })
        hi("TelescopeBorder",           { fg = c.base03 })
        hi("TelescopePromptBorder",     { fg = c.base03 })
        hi("TelescopeResultsBorder",    { fg = c.base03 })
        hi("TelescopePreviewBorder",    { fg = c.base03 })
        hi("NeoTreeNormal",             { bg = c.base00, fg = c.base05 })
        hi("NeoTreeNormalNC",           { bg = c.base00 })
      '';

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
        enable = true;
        formatOnSave = false;
        lspkind.enable = false;
        lightbulb.enable = false;
        lspsaga.enable = false;
        trouble.enable = false;
        nvim-docs-view.enable = false;
      };

      # ── Languages ─────────────────────────────────────────────────────
      languages = {
        enableLSP = true;
        enableTreesitter = true;

        clang = {
          enable = true;
          lsp.enable = true;
          treesitter.enable = true;
        };

        lua = {
          enable = true;
          lsp.enable = true;
          treesitter.enable = true;
        };

        nix = {
          enable = true;
          lsp.enable = false;       # No reliable Nix LSP
          treesitter.enable = true;
        };

        julia = {
          enable = true;
          lsp.enable = false;       # No reliable Julia LSP
          treesitter.enable = true;
        };
      };

      # ── Completion ────────────────────────────────────────────────────
      autocomplete.nvim-cmp.enable = true;

      # ── UI plugins ────────────────────────────────────────────────────
      telescope.enable = true;

      statusline.lualine = {
        enable = true;
        theme = "auto";
      };

      treesitter = {
        enable = true;
        fold = false;
        highlight.enable = true;
        indent.enable = true;
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
