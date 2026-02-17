{ config, pkgs, ... }:

{
  # Applications
  home.packages = with pkgs; [
    mpv           # Media player
    nicotine-plus # Soulseek client (GUI)

    # DAW
    reaper

    # ── Audio plugins ──────────────────────────────────────────────────────────
    lsp-plugins      # Linux Studio Plugins (LSP) - compressors, EQs, dynamics
    surge-XT         # Surge synthesizer
    cardinal         # Cardinal modular (VCV Rack based)
    dexed            # FM synthesizer (Yamaha DX7 emulation)
    airwindows-lv2   # Airwindows consolidated (hundreds of effects, LV2)
    dragonfly-reverb # Dragonfly hall/room/plate/early reverb suite
    chow-tape-model  # Chowdhury DSP tape machine emulation
    ChowPhaser       # Chowdhury DSP phaser
    ChowKick         # Chowdhury DSP kick drum synth
    ChowCentaur      # Chowdhury DSP Centaur pedal emulation

    # Voxengo SPAN - free spectrum analyzer VST3
    # ── NOTE: First-time setup required ────────────────────────────────────────
    # voxengo-span is a custom package defined in pkgs/voxengo-span/default.nix
    # It will not build until you fill in the correct sha256 hash.
    #
    # Steps to activate it:
    #   1. Find the current download URL on https://www.voxengo.com/product/span/
    #   2. Run: nix-prefetch-url --unpack <url>
    #   3. Paste the output hash into pkgs/voxengo-span/default.nix
    #   4. Remove the `broken = true;` line from that file's meta block
    #   5. Run: sudo nixos-rebuild switch --flake /etc/nixos#leavenworth
    #
    # Once activated, SPAN's VST3 will be installed to:
    #   /nix/store/<hash>-voxengo-span-<ver>/lib/vst3/SPAN.vst3
    # Add that path to Reaper's VST3 scan paths in Preferences → Plug-ins → VST.
    voxengo-span

    # PipeWire graph/patchbay
    qpwgraph

    # ── Creative apps ──────────────────────────────────────────────────────────
    davinci-resolve
    blender
    krita

    # Torrents
    qbittorrent

    # Screen recording / streaming
    obs-studio
  ];

  # Create directories on install - using .keep files to create empty dirs
  home.file = {
    "Music/.keep".text                        = "";
    "Downloads/nicotine/.keep".text           = "";
    "Pictures/Screenshots/.keep".text         = "";
    "Documents/Samples/.keep".text            = "";
    "Documents/Reaper/.keep".text             = "";
    "Documents/Reaper/Peaks/.keep".text       = "";
    "Documents/Reaper/Projects/.keep".text    = "";
    "Documents/Reaper/Backups/.keep".text     = "";
    "Documents/Resolve/Projects/.keep".text   = "";
    "Documents/Blender/.keep".text            = "";
    "Documents/Krita/.keep".text              = "";
    "Videos/Movies/.keep".text                = "";
    "Videos/Shows/.keep".text                 = "";
  };

  # Librewolf browser - Firefox-based, privacy focused
  programs.librewolf = {
    enable = true;

    settings = {
      # ── Sync ──────────────────────────────────────────────────────────────────
      "identity.fxaccounts.enabled" = true;

      # ── Session / tabs ────────────────────────────────────────────────────────
      "browser.startup.page" = 3;
      "browser.sessionstore.resume_session_once" = false;
      "browser.sessionstore.max_tabs_undo" = 10;

      # ── Logins / passwords ────────────────────────────────────────────────────
      "signon.rememberSignons" = true;
      "privacy.clearOnShutdown.passwords" = false;
      "privacy.clearOnShutdown_v2.passwords" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.sessions" = false;

      # ── History ───────────────────────────────────────────────────────────────
      "privacy.clearOnShutdown.formdata" = true;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.sanitize.sanitizeOnShutdown" = true;

      # ── Appearance ────────────────────────────────────────────────────────────
      "browser.tabs.inTitlebar" = 0;
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 0;
      "browser.theme.toolbar-theme" = 0;

      # ── Performance ───────────────────────────────────────────────────────────
      "gfx.webrender.all" = true;

      # ── LibreWolf overrides ───────────────────────────────────────────────────
      "browser.aboutConfig.showWarning" = false;
      # resistFingerprinting breaks Firefox sync; disable it
      "privacy.resistFingerprinting" = false;

      # ── Search ────────────────────────────────────────────────────────────────
      "browser.search.defaultenginename" = "DuckDuckGo";
    };
  };

  # Beets music library management
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
        "[\\\\\/]"       = "_";
        "^\\."           = "_";
        "[\\x00-\\x1f]"  = "_";
        "[<>:\"\\?\\*\\|]" = "_";
        "\\.$"           = "_";
        "\\s+$"          = "";
      };
      
      plugins = [ "fetchart" "embedart" "scrub" "replaygain" "lastgenre" "chroma" ];
      
      fetchart.auto    = true;
      fetchart.cautious = true;
      embedart.auto    = true;
      replaygain.auto  = false;
      lastgenre.auto   = true;
      lastgenre.source = "track";
    };
  };
}
