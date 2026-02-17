{ config, pkgs, ... }:

{
  # Applications
  home.packages = with pkgs; [
    mpv           # Media player
    nicotine-plus # Soulseek client (GUI)
  ];

  # Create directories
  home.file = {
    "Music/.keep".text = "";
    "Downloads/nicotine/.keep".text = "";
    "Pictures/Screenshots/.keep".text = "";
  };

  # Librewolf browser - Firefox-based, privacy focused
  programs.librewolf = {
    enable = true;

    settings = {
      # Firefox sync - sign in at about:preferences#sync
      "identity.fxaccounts.enabled" = true;

      # Restore tabs on restart
      "browser.startup.page" = 3;
      "browser.sessionstore.resume_session_once" = true;
      "browser.sessionstore.max_tabs_undo" = 10;

      # Titlebar - use system titlebar
      "browser.tabs.inTitlebar" = 0;

      # Force dark mode - uses GTK theme from environment
      "ui.systemUsesDarkTheme" = 1;
      "browser.theme.content-theme" = 0;   # 0 = dark
      "browser.theme.toolbar-theme" = 0;   # 0 = dark

      # Wayland rendering
      "gfx.webrender.all" = true;

      # LibreWolf overrides
      "browser.aboutConfig.showWarning" = false;
      "privacy.resistFingerprinting" = false;

      # Search
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
        strong_rec_thresh = 0.10;  # Threshold for very strong matches
        medium_rec_thresh = 0.25;  # Threshold for medium matches
        rec_gap_thresh = 0.25;     # Gap between first and second match
      };
      
      # Paths - organize music by artist/album
      paths = {
        default = "$albumartist/$album%aunique{}/$track $title";
        singleton = "$artist/Singles/$title";
        comp = "Compilations/$album%aunique{}/$track $title";
      };
      
      # Replace characters in filenames
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
      
      # Plugin settings
      fetchart = {
        auto = true;
        cautious = true;
      };
      
      embedart = {
        auto = true;
      };
      
      replaygain = {
        auto = false;  # Manual, as it can be CPU intensive
      };
      
      lastgenre = {
        auto = true;
        source = "track";
      };
    };
  };
}
