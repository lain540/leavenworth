{ config, pkgs, lib, ... }:

{
  # Neovim via nvf — https://github.com/NotAShelf/nvf
  # stylix.targets.nvf (bottom of file) owns vim.theme and lualine.theme.
  # Do not set either here or evaluation will fail with "conflicting definition".

  programs.nvf = {
    enable = true;

    settings.vim = {

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

      maps.normal = {
        "<leader>e"  = { action = "<cmd>Yazi<CR>";                          desc = "Open yazi"; };
        "<leader>ff" = { action = "<cmd>Telescope find_files<CR>";          desc = "Find files"; };
        "<leader>fg" = { action = "<cmd>Telescope live_grep<CR>";           desc = "Live grep"; };
        "<leader>fb" = { action = "<cmd>Telescope buffers<CR>";             desc = "Buffers"; };
        "gd"         = { action = "<cmd>lua vim.lsp.buf.definition()<CR>";  desc = "Go to definition"; };
        "K"          = { action = "<cmd>lua vim.lsp.buf.hover()<CR>";       desc = "LSP hover"; };
        "<leader>rn" = { action = "<cmd>lua vim.lsp.buf.rename()<CR>";      desc = "Rename"; };
        "<leader>ca" = { action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; desc = "Code action"; };
      };

      lsp = {
        enable            = true;
        formatOnSave      = false;
        lspkind.enable    = false;
        lightbulb.enable  = false;
        lspsaga.enable    = false;
        trouble.enable    = false;
        nvim-docs-view.enable = false;
      };

      languages = {
        clang  = { enable = true; lsp.enable = true;  treesitter.enable = true; };
        lua    = { enable = true; lsp.enable = true;  treesitter.enable = true; };
        nix    = { enable = true; lsp.enable = false; treesitter.enable = true; };
        julia  = { enable = true; lsp.enable = false; treesitter.enable = true; };
        python = { enable = true; lsp.enable = true;  treesitter.enable = true; };
        rust   = { enable = true; lsp.enable = true;  treesitter.enable = true; };
        bash   = { enable = true; lsp.enable = true;  treesitter.enable = true; };
      };

      autocomplete.nvim-cmp.enable = true;
      telescope.enable             = true;
      filetree.neo-tree.enable     = true;

      statusline.lualine = { enable = true; /* theme set by stylix */ };

      treesitter = {
        enable           = true;
        fold             = false;
        highlight.enable = true;
        indent.enable    = true;
      };

      # Yazi integration
      extraPlugins.yazi-nvim = {
        package = pkgs.vimPlugins.yazi-nvim;
        setup   = ''
          require("yazi").setup({
            open_for_directories = false,
            keymaps = { show_help = "<f1>" },
          })
        '';
      };
    };
  };

  # Owns vim.theme and lualine.theme — must not be set above
  stylix.targets.nvf.enable = true;
}
