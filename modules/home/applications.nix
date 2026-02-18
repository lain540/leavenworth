{ config, pkgs, ... }:

{
  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # DAW — launch with `pw-jack reaper` for JACK/MIDI support
    reaper

    # PipeWire patchbay
    qpwgraph

    # Creative
    davinci-resolve
    blender
    krita

    # Media
    mpv
    obs-studio

    # Misc
    nicotine-plus
    qbittorrent
  ];

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

  # ── Librewolf ─────────────────────────────────────────────────────────────────
  programs.librewolf = {
    enable = true;

    profiles.default = {
      id        = 0;
      name      = "default";
      isDefault = true;

      settings = {
        # Sync
        "identity.fxaccounts.enabled" = true;

        # Session restore
        "browser.startup.page"                     = 3;
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.max_tabs_undo"       = 10;

        # Keep cookies / passwords / sessions across restarts
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

        # Appearance
        "browser.tabs.inTitlebar"     = 0;
        "ui.systemUsesDarkTheme"      = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;

        # Misc
        "gfx.webrender.all"                = true;
        "browser.aboutConfig.showWarning"  = false;
        "privacy.resistFingerprinting"     = false;
        "browser.search.defaultenginename" = "DuckDuckGo";
      };
    };
  };

  # ── Beets — music library manager ─────────────────────────────────────────────
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
}
