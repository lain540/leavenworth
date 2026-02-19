{ config, pkgs, lib, ... }:

{
  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # DAW — launch with `pw-jack reaper` for JACK/MIDI support
    reaper
    reaper-reapack-extension  # package manager for REAPER scripts and plugins
    reaper-sws-extension      # SWS/S&M extension — hundreds of extra actions

    # PipeWire patchbay
    qpwgraph

    # Creative
    davinci-resolve blender krita

    # Media
    mpv obs-studio

    # Misc
    nicotine-plus qbittorrent

    # Yazi previewer dependencies
    ffmpegthumbnailer unar jq poppler-utils imagemagick file
  ];

  # ── Reaper / ReaPack library access ──────────────────────────────────────────
  # ReaPack scripts run inside Reaper's embedded Lua interpreter. When they
  # call require() on a C extension (e.g. luasocket, luafilesystem) the
  # interpreter searches LUA_CPATH. On NixOS all Lua libs are in the nix store
  # so we point LUA_CPATH at the system profile's Lua 5.4 cpath.
  # LUA_PATH covers pure-Lua modules in the same location.
  home.sessionVariables = {
    LUA_PATH  = "/run/current-system/sw/share/lua/5.4/?.lua;/run/current-system/sw/share/lua/5.4/?/init.lua;;";
    LUA_CPATH = "/run/current-system/sw/lib/lua/5.4/?.so;;";

    # ReaPack downloads pre-compiled .so extensions (ReaImGui etc.) that link
    # against standard Linux library paths which don't exist on NixOS.
    # Pointing LD_LIBRARY_PATH at the system profile's lib dir makes them find
    # freetype, gtk3, cairo, glib, fontconfig, libepoxy and friends at runtime.
    LD_LIBRARY_PATH = "/run/current-system/sw/lib";
  };

  # ── Directory scaffold ────────────────────────────────────────────────────────
  home.file = {
    "Music/.keep".text                      = "";
    "Downloads/nicotine/.keep".text         = "";
    "Pictures/Screenshots/.keep".text       = "";
    "Documents/Samples/.keep".text          = "";
    "Documents/Reaper/Projects/.keep".text  = "";
    "Documents/Reaper/Peaks/.keep".text     = "";
    "Documents/Reaper/Backups/.keep".text   = "";
    "Documents/Resolve/Projects/.keep".text = "";
    "Documents/Blender/.keep".text          = "";
    "Documents/Krita/.keep".text            = "";
    "Videos/Movies/.keep".text              = "";
    "Videos/Shows/.keep".text               = "";
  };

  # ── Yazi ──────────────────────────────────────────────────────────────────────
  programs.yazi = {
    enable               = true;
    enableZshIntegration = true;
    shellWrapperName     = "y";
    settings = {
      manager = { show_hidden = false; sort_by = "natural"; sort_dir_first = true; };
      preview = { image_protocol = "sixel"; max_width = 600; max_height = 900; };
    };
  };

  # ── Librewolf ─────────────────────────────────────────────────────────────────
  programs.librewolf = {
    enable = true;

    profiles.default = {
      id        = 0;
      name      = "default";
      isDefault = true;

      settings = {
        "identity.fxaccounts.enabled" = true;

        "browser.startup.page"                     = 3;
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.max_tabs_undo"       = 10;

        "signon.rememberSignons"                       = true;
        "privacy.clearOnShutdown.passwords"            = false;
        "privacy.clearOnShutdown_v2.passwords"         = false;
        "privacy.clearOnShutdown.cookies"              = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        "privacy.clearOnShutdown.offlineApps"          = false;
        "privacy.clearOnShutdown.sessions"             = false;
        "privacy.clearOnShutdown.formdata"             = true;
        "privacy.clearOnShutdown.history"              = false;
        "privacy.clearOnShutdown.downloads"            = false;
        "privacy.sanitize.sanitizeOnShutdown"          = true;

        "browser.tabs.inTitlebar"     = 0;
        "ui.systemUsesDarkTheme"      = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;

        "gfx.webrender.all"                = true;
        "browser.aboutConfig.showWarning"  = false;
        "privacy.resistFingerprinting"     = false;
        "browser.search.defaultenginename" = "DuckDuckGo";
      };
    };
  };

  # ── Beets ─────────────────────────────────────────────────────────────────────
  programs.beets = {
    enable   = true;
    settings = {
      directory = "~/Music";
      library   = "~/Music/library.db";

      import = {
        move = true; write = true; copy = false; delete = false;
        timid = false; quiet_fallback = "skip"; incremental = true;
      };

      match = {
        strong_rec_thresh = 0.10;
        medium_rec_thresh = 0.25;
        rec_gap_thresh    = 0.25;
      };

      paths = {
        default   = "$albumartist/$album%aunique{}/$track $title";
        singleton = "$artist/Singles/$title";
        comp      = "Compilations/$album%aunique{}/$track $title";
      };

      replace = {
        "[\\\\/]"          = "_";
        "^\\."             = "_";
        "[\\x00-\\x1f]"    = "_";
        "[<>:\"\\?\\*\\|]" = "_";
        "\\.$"             = "_";
        "\\s+$"            = "";
      };

      plugins = [ "fetchart" "embedart" "scrub" "replaygain" "lastgenre" "chroma" ];

      fetchart   = { auto = true; cautious = true; };
      embedart   = { auto = true; };
      replaygain = { auto = false; };
      lastgenre  = { auto = true; source = "track"; };
    };
  };

  # ── Neovim via nvf ────────────────────────────────────────────────────────────
  # stylix.targets.nvf (bottom) owns vim.theme + lualine.theme — do not set them above.
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
      statusline.lualine.enable    = true;

      treesitter = {
        enable           = true;
        fold             = false;
        highlight.enable = true;
        indent.enable    = true;
      };

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

  stylix.targets.nvf.enable = true;
}
