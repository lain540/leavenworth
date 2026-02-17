{ config, pkgs, lib, ... }:

{
  # Neovim via nvf - https://github.com/NotAShelf/nvf
  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        # ── Editor options ────────────────────────────────────────────────
        lineNumberMode = "relNumber";     # Relative line numbers
        tabstop = 2;
        shiftwidth = 2;
        expandTab = true;
        autoIndent = "smart";
        wordWrap = false;
        scrollOffset = 8;
        updateTime = 50;
        useSystemClipboard = true;

        options = {
          swapfile = false;
          backup = false;
          hlsearch = true;
          incsearch = true;
          termguicolors = true;
        };

        # Space as leader
        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        # ── Colorscheme - base16-default-dark to match foot / system ─────
        # These are the exact same hex values used in foot and waybar
        theme = {
          enable = true;
          name = "base16";
          style = "dark";
          transparent = false;
        };

        # Manual highlight overrides so nvim matches the system palette
        luaConfigRC.colorOverrides = lib.nvim.dag.entryAnywhere ''
          -- base16-default-dark palette
          -- Matches foot terminal and waybar exactly
          local c = {
            base00 = "#181818", -- background
            base01 = "#282828", -- lighter background
            base02 = "#383838", -- selection background
            base03 = "#585858", -- comments
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

          vim.cmd("highlight Normal       guibg=" .. c.base00 .. " guifg=" .. c.base05)
          vim.cmd("highlight NormalFloat  guibg=" .. c.base01 .. " guifg=" .. c.base05)
          vim.cmd("highlight LineNr       guifg=" .. c.base03)
          vim.cmd("highlight CursorLineNr guifg=" .. c.base05)
          vim.cmd("highlight Comment      guifg=" .. c.base03 .. " gui=italic")
          vim.cmd("highlight StatusLine   guibg=" .. c.base01 .. " guifg=" .. c.base04)
          vim.cmd("highlight Visual       guibg=" .. c.base02)
          vim.cmd("highlight Search       guibg=" .. c.base0A .. " guifg=" .. c.base00)
          vim.cmd("highlight Pmenu        guibg=" .. c.base01 .. " guifg=" .. c.base05)
          vim.cmd("highlight PmenuSel     guibg=" .. c.base02 .. " guifg=" .. c.base06)
          vim.cmd("highlight TelescopeNormal guibg=" .. c.base00)
          vim.cmd("highlight TelescopeBorder guifg=" .. c.base03)
        '';

        # ── Keymaps ───────────────────────────────────────────────────────
        maps.normal = {
          # Open yazi file manager
          "<leader>e" = {
            action = "<cmd>Yazi<CR>";
            desc = "Open yazi file manager";
          };
          # Telescope
          "<leader>ff" = {
            action = "<cmd>Telescope find_files<CR>";
            desc = "Find files";
          };
          "<leader>fg" = {
            action = "<cmd>Telescope live_grep<CR>";
            desc = "Live grep";
          };
          "<leader>fb" = {
            action = "<cmd>Telescope buffers<CR>";
            desc = "Find buffers";
          };
          # LSP
          "gd" = {
            action = "<cmd>lua vim.lsp.buf.definition()<CR>";
            desc = "Go to definition";
          };
          "K" = {
            action = "<cmd>lua vim.lsp.buf.hover()<CR>";
            desc = "LSP hover";
          };
          "<leader>rn" = {
            action = "<cmd>lua vim.lsp.buf.rename()<CR>";
            desc = "LSP rename";
          };
          "<leader>ca" = {
            action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
            desc = "Code action";
          };
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

        languages = {
          enableLSP = true;
          enableTreesitter = true;

          # C/C++
          clang = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };

          # Lua
          lua = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };

          # Nix - treesitter only (no reliable LSP)
          nix = {
            enable = true;
            lsp.enable = false;
            treesitter.enable = true;
          };

          # Julia - treesitter only
          julia = {
            enable = true;
            lsp.enable = false;
            treesitter.enable = true;
          };
        };

        # ── Plugins ───────────────────────────────────────────────────────

        # Completion
        autocomplete.nvim-cmp = {
          enable = true;
          sources.nvim-lsp = "[LSP]";
          sources.path = "[Path]";
          sources.buffer = "[Buffer]";
        };

        # Telescope fuzzy finder
        telescope.enable = true;

        # Status line
        statusline.lualine = {
          enable = true;
          theme = "base16";
        };

        # Syntax highlighting
        treesitter = {
          enable = true;
          fold = false;
          highlight.enable = true;
          indent.enable = true;
        };

        # File tree
        filetree.neo-tree = {
          enable = true;
        };

        # Yazi file manager integration
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
  };
}
