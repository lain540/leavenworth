{ config, pkgs, ... }:

# musnix (enabled in configuration.nix) automatically sets VST_PATH, VST3_PATH,
# LXVST_PATH, LADSPA_PATH, LV2_PATH and DSSI_PATH to the correct NixOS store
# locations at the system level — no manual env var setup needed here.
# See: https://github.com/musnix/musnix

{
  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    mpv           # Media player
    nicotine-plus # Soulseek client (GUI)

    # ── DAW ───────────────────────────────────────────────────────────────────
    reaper

    # ── Audio plugins ─────────────────────────────────────────────────────────
    # All plugins ship their files under lib/vst3 or lib/lv2 in the nix store.
    # musnix sets the plugin path variables so Reaper finds them automatically.
    lsp-plugins      # Linux Studio Plugins — compressors, EQs, dynamics (LV2/VST3)
    surge-XT         # Surge XT — subtractive/wavetable synth (VST3/LV2)
    cardinal         # Cardinal — VCV Rack modular (VST3/LV2)
    dexed            # Dexed — Yamaha DX7 FM emulation (VST3)
    airwindows-lv2   # Airwindows — hundreds of subtle effect ports (LV2)
    dragonfly-reverb # Dragonfly — hall/room/plate reverb suite (VST3/LV2)
    chow-tape-model  # CHOWTapeModel — analog tape machine emulation (VST3)
    chow-phaser      # Chowdhury DSP phaser (VST3)       [was: ChowPhaser]
    chow-kick        # Chowdhury DSP kick drum synth (VST3) [was: ChowKick]
    chow-centaur     # Chowdhury DSP Klon Centaur emulation (VST3) [was: ChowCentaur]

    # ── PipeWire patchbay ──────────────────────────────────────────────────────
    qpwgraph  # Visual audio/MIDI routing graph for PipeWire

    # ── Creative apps ──────────────────────────────────────────────────────────
    davinci-resolve
    blender
    krita

    # ── General ───────────────────────────────────────────────────────────────
    qbittorrent
    obs-studio
  ];

  # ── Directory scaffold ────────────────────────────────────────────────────
  home.file = {
    "Music/.keep".text                      = "";
    "Downloads/nicotine/.keep".text         = "";
    "Pictures/Screenshots/.keep".text       = "";
    "Documents/Samples/.keep".text          = "";
    "Documents/Reaper/.keep".text           = "";
    "Documents/Reaper/Peaks/.keep".text     = "";
    "Documents/Reaper/Projects/.keep".text  = "";
    "Documents/Reaper/Backups/.keep".text   = "";
    "Documents/Resolve/Projects/.keep".text = "";
    "Documents/Blender/.keep".text          = "";
    "Documents/Krita/.keep".text            = "";
    "Videos/Movies/.keep".text              = "";
    "Videos/Shows/.keep".text               = "";
  };

  # ── Librewolf ─────────────────────────────────────────────────────────────
  programs.librewolf = {
    enable = true;

    profiles.default = {
      id        = 0;
      name      = "default";
      isDefault = true;

      # ── userChrome.css — base16 toolbar theming ────────────────────────────
      # toolkit.legacyUserProfileCustomizations.stylesheets (below) MUST be
      # true or Firefox/Librewolf silently ignores this file entirely.
      # Colors are pulled from config.lib.stylix.colors at build time so
      # changing the scheme in configuration.nix recolors the browser too.
      userChrome = with config.lib.stylix.colors; ''
        /* ── base16 toolbar / chrome theme ── */
        :root {
          --base00: #${base00};  /* background */
          --base01: #${base01};  /* lighter bg / tab bar */
          --base02: #${base02};  /* selection */
          --base03: #${base03};  /* comments / inactive */
          --base04: #${base04};  /* dark fg */
          --base05: #${base05};  /* default fg */
          --base06: #${base06};  /* light fg */
          --base07: #${base07};  /* light bg */
          --base08: #${base08};  /* red / errors */
          --base0D: #${base0D};  /* blue / links */
        }

        /* Window background */
        #navigator-toolbox {
          background-color: var(--base00) !important;
          border-bottom: 1px solid var(--base02) !important;
        }

        /* Tab bar */
        .tabbrowser-tab {
          background-color: var(--base01) !important;
          color: var(--base04) !important;
        }
        .tabbrowser-tab[selected] {
          background-color: var(--base02) !important;
          color: var(--base05) !important;
        }
        .tabbrowser-tab:hover {
          background-color: var(--base02) !important;
          color: var(--base05) !important;
        }

        /* URL bar */
        #urlbar, #urlbar-input {
          background-color: var(--base01) !important;
          color: var(--base05) !important;
          border-color: var(--base03) !important;
        }
        #urlbar:focus-within {
          border-color: var(--base0D) !important;
        }

        /* Toolbar buttons */
        toolbar {
          background-color: var(--base00) !important;
          color: var(--base05) !important;
        }
        toolbarbutton:hover {
          background-color: var(--base02) !important;
        }
      '';

      settings = {
        # REQUIRED: load userChrome.css / userContent.css
        # Without this Firefox silently ignores the files above.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Sync
        "identity.fxaccounts.enabled" = true;

        # Session restore
        "browser.startup.page"                     = 3;
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.max_tabs_undo"       = 10;

        # Stay logged in between sessions
        "signon.rememberSignons"                       = true;
        "privacy.clearOnShutdown.passwords"            = false;
        "privacy.clearOnShutdown_v2.passwords"         = false;
        "privacy.clearOnShutdown.cookies"              = false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        "privacy.clearOnShutdown.offlineApps"          = false;
        "privacy.clearOnShutdown.sessions"             = false;

        "privacy.clearOnShutdown.formdata"    = true;
        "privacy.clearOnShutdown.history"     = false;
        "privacy.clearOnShutdown.downloads"   = false;
        "privacy.sanitize.sanitizeOnShutdown" = true;

        # Appearance
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

  # ── Beets music library ───────────────────────────────────────────────────
  programs.beets = {
    enable = true;

    settings = {
      directory = "~/Music";
      library   = "~/Music/library.db";

      import = {
        move           = true;
        write          = true;
        copy           = false;
        delete         = false;
        timid          = false;
        quiet_fallback = "skip";
        incremental    = true;
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
        "[\\\\\/]"         = "_";
        "^\\."             = "_";
        "[\\x00-\\x1f]"    = "_";
        "[<>:\"\\?\\*\\|]" = "_";
        "\\.$"             = "_";
        "\\s+$"            = "";
      };

      plugins = [ "fetchart" "embedart" "scrub" "replaygain" "lastgenre" "chroma" ];

      fetchart.auto     = true;
      fetchart.cautious = true;
      embedart.auto     = true;
      replaygain.auto   = false;
      lastgenre.auto    = true;
      lastgenre.source  = "track";
    };
  };
}
