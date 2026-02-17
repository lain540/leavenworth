{ config, pkgs, ... }:

{
  # Applications
  home.packages = with pkgs; [
    mpv           # Media player
    nicotine-plus # Soulseek client (GUI)

    # DAW
    reaper

    # Audio plugins
    lsp-plugins      # Linux Studio Plugins (LSP)
    surge-XT         # Surge synthesizer
    cardinal         # Cardinal modular (VCV Rack based)
    dexed            # FM synthesizer (Yamaha DX7 emulation)
    airwindows-lv2   # Airwindows consolidated (hundreds of effects, LV2)
    dragonfly-reverb # Dragonfly hall/room/plate/early reverb suite
    CHOWTapeModel    # Chowdhury DSP tape machine emulation
    ChowPhaser       # Chowdhury DSP phaser
    ChowKick         # Chowdhury DSP kick drum synth
    ChowCentaur      # Chowdhury DSP Centaur pedal emulation

    # PipeWire graph/patchbay
    qpwgraph

    # Video editing
    davinci-resolve

    # 3D creation
    blender

    # Torrents
    qbittorrent

    # Screen recording / streaming
    obs-studio

    # Digital painting / illustration
    krita
  ];

  # Create directories on install - using .keep files to create empty dirs
  # home-manager will create the parent directories automatically
  home.file = {
    # Music & downloads
    "Music/.keep".text                        = "";
    "Downloads/nicotine/.keep".text           = "";

    # Screenshots
    "Pictures/Screenshots/.keep".text         = "";

    # Audio production
    "Documents/Samples/.keep".text            = "";
    "Documents/Reaper/.keep".text             = "";
    "Documents/Reaper/Peaks/.keep".text       = "";
    "Documents/Reaper/Projects/.keep".text    = "";
    "Documents/Reaper/Backups/.keep".text     = "";

    # Video editing
    "Documents/Resolve/Projects/.keep".text   = "";

    # Creative apps
    "Documents/Blender/.keep".text            = "";
    "Documents/Krita/.keep".text              = "";

    # Video library
    "Videos/Movies/.keep".text                = "";
    "Videos/Shows/.keep".text                 = "";
  };

  # Librewolf browser - Firefox-based, privacy focused
  programs.librewolf = {
    enable = true;

    settings = {
      # ── Sync ─────────────────────────────────────────────────────────────
      # Sign in at about:preferences#sync after first launch
      "identity.fxaccounts.enabled" = true;

      # ── Session / tabs ────────────────────────────────────────────────────
      # Restore previous session (open tabs) on every start
      "browser.startup.page" = 3;
      "browser.sessionstore.resume_session_once" = false; # Always restore, not just once
      "browser.sessionstore.max_tabs_undo" = 10;

      # ── Logins / passwords ────────────────────────────────────────────────
      # Remember which sites you're logged in to
      "signon.rememberSignons" = true;
      # Do NOT clear logins on shutdown
      "privacy.clearOnShutdown.passwords" = false;
      "privacy.clearOnShutdown_v2.passwords" = false;
      # Do NOT clear cookies on shutdown (needed to stay logged in)
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      # Keep site data between sessions
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.sessions" = false;

      # ── History - only clear search/URL bar history ────────────────────────
      # Clear typed history (address bar searches) on shutdown
      "privacy.clearOnShutdown.formdata" = true;
      # But keep full browsing history so session works
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;

      # LibreWolf by default clears everything; disable the global setting
      # so per-item settings above are respected
      "privacy.sanitize.sanitizeOnShutdown" = true; # Still sanitize, but only formdata

      # ── Appearance ────────────────────────────────────────────────────────
      # System titlebar
      "browser.tabs.inTitlebar" = 0;
      # Dark mode
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 0;
      "browser.theme.toolbar-theme" = 0;

      # ── Performance ───────────────────────────────────────────────────────
      "gfx.webrender.all" = true;

      # ── LibreWolf overrides ───────────────────────────────────────────────
      "browser.aboutConfig.showWarning" = false;
      # resistFingerprinting breaks Firefox sync; disable it
      "privacy.resistFingerprinting" = false;

      # ── Search ────────────────────────────────────────────────────────────
      "browser.search.defaultenginename" = "DuckDuckGo";
    };
  };

  # Beets music library management
  programs.beets = {
    enable = true;
    
    settings = {
      # Library location
      directory = "~/Music";
      library = "~/Music/library.db";
      
      # Import settings
      import = {
        move = true;              # Move files (not copy) into library
        write = true;             # Write tags to files
        copy = false;             # Don't copy, move instead
        delete = false;           # Don't delete originals after import
        timid = false;            # Don't ask for confirmation on every album
        quiet_fallback = "skip";  # Skip albums without good matches
        incremental = true;       # Skip already-imported albums
      };
      
      # Auto-tagging
      match = {
        strong_rec_thresh = 0.10;
        medium_rec_thresh = 0.25;
        rec_gap_thresh = 0.25;
      };
      
      # Paths - organize music by artist/album
      paths = {
        default = "$albumartist/$album%aunique{}/$track $title";
        singleton = "$artist/Singles/$title";
        comp = "Compilations/$album%aunique{}/$track $title";
      };
      
      # Replace illegal characters in filenames
      replace = {
        "[\\\\\/]" = "_";
        "^\\." = "_";
        "[\\x00-\\x1f]" = "_";
        "[<>:\"\\?\\*\\|]" = "_";
        "\\.$" = "_";
        "\\s+$" = "";
      };
      
      # Plugins
      plugins = [ "fetchart" "embedart" "scrub" "replaygain" "lastgenre" "chroma" ];
      
      fetchart = {
        auto = true;
        cautious = true;
      };
      
      embedart = {
        auto = true;
      };
      
      replaygain = {
        auto = false;  # Manual - CPU intensive
      };
      
      lastgenre = {
        auto = true;
        source = "track";
      };
    };
  };
}
