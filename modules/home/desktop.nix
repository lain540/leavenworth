{ config, pkgs, inputs, ... }:

{
  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard wlr-randr hyprshot

    # Audio / media control
    wireplumber playerctl

    # Blue light filter — toggle via `killall wlsunset` or rebind a key
    wlsunset
  ];

  # ── GTK ───────────────────────────────────────────────────────────────────────
  # stylix owns gtk.theme, gtk.font, gtk.cursorTheme — only icons live here.
  # home.pointerCursor is set automatically by stylix.cursor in configuration.nix.
  gtk = {
    enable    = true;
    iconTheme = { name = "Tela-Black"; package = pkgs.tela-icon-theme; };
    gtk3.extraConfig.gtk-decoration-layout = "";
    gtk4.extraConfig.gtk-decoration-layout = "";
  };

  # ── MIME — default file manager ───────────────────────────────────────────────
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"              = "yazi.desktop";
      "application/zip"              = "yazi.desktop";
      "application/x-tar"            = "yazi.desktop";
      "application/x-bzip2"          = "yazi.desktop";
      "application/x-gzip"           = "yazi.desktop";
      "application/x-xz"             = "yazi.desktop";
      "application/x-zstd"           = "yazi.desktop";
      "application/x-rar"            = "yazi.desktop";
      "application/x-7z-compressed"  = "yazi.desktop";
    };
  };

  # ── Fuzzel launcher ───────────────────────────────────────────────────────────
  # Colors and font set by stylix.targets.fuzzel
  programs.fuzzel = {
    enable   = true;
    settings = {
      main   = { lines = 10; width = 40; terminal = "foot"; icons-enabled = false; };
      border = { width = 1; radius = 0; };
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable          = true;
    xwayland.enable = true;

    settings = {
      # Monitors
      # Real hardware: 3440×1440 ultrawide (bottom) + 1920×1080 centred above it
      # x-offset = (2752 - 1920) / 2 = 416
      monitor = [
        "HDMI-A-1,3440x1440@60,0x1080,1.25"
        "DP-1,1920x1080@60,416x0,1"
      ];
      # VirtualBox: comment out above, uncomment below
      # monitor = [ "Virtual-1,1920x1080@60,0x0,1" ];

      # Input
      input = {
        kb_layout  = "us,se";
        kb_variant = "workman,";
        kb_options = "";
        follow_mouse            = 1;
        sensitivity             = 0;
        touchpad.natural_scroll = false;
      };

      cursor.no_hardware_cursors = true;

      env = [
        "XCURSOR_THEME,Adwaita" "XCURSOR_SIZE,24"
        "EDITOR,nvim"           "VISUAL,nvim"
        "MOZ_ENABLE_WAYLAND,1"  "MOZ_GTK_TITLEBAR_DECORATION,client"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "FILE_MANAGER,yazi"
      ];

      # Borders pull from the active stylix scheme automatically
      general = {
        gaps_in     = 0;
        gaps_out    = 0;
        border_size = 2;
        "col.active_border"   = "rgba(${config.lib.stylix.colors.base05}ff)";
        "col.inactive_border" = "rgba(${config.lib.stylix.colors.base03}aa)";
        layout = "dwindle";
      };

      decoration = { rounding = 0; blur.enabled = false; shadow.enabled = false; };
      animations.enabled = false;
      dwindle = { pseudotile = true; preserve_split = true; };

      misc = { disable_hyprland_logo = true; disable_splash_rendering = true; };

      "$mod" = "SUPER";

      bind = [
        # Apps
        "$mod, Return,  exec, foot"
        "$mod, d,       exec, fuzzel"
        "$mod, w,       exec, foot -e yazi"
        "$mod, q,       killactive"
        "$mod SHIFT, q, exit"
        "$mod, f,       fullscreen"
        "$mod, t,       togglefloating"
        "$mod, s,       togglesplit"
        "$mod, p,       pseudo"
        "$mod, a,       exec, qpwgraph"

        # Keyboard layout — cycle us/workman ↔ se
        "$mod, Space, exec, hyprctl switchxkblayout all next"

        # Focus (Workman: Y N E O = H J K L)
        "$mod, y, movefocus, l"   "$mod, n, movefocus, d"
        "$mod, e, movefocus, u"   "$mod, o, movefocus, r"
        "$mod, left,  movefocus, l"  "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"  "$mod, down,  movefocus, d"

        # Move windows
        "$mod SHIFT, y, movewindow, l"  "$mod SHIFT, n, movewindow, d"
        "$mod SHIFT, e, movewindow, u"  "$mod SHIFT, o, movewindow, r"
        "$mod SHIFT, left,  movewindow, l"  "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"  "$mod SHIFT, down,  movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"   "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod, 2, workspace, 2"   "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod, 3, workspace, 3"   "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod, 4, workspace, 4"   "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod, 5, workspace, 5"   "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod, 6, workspace, 6"   "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod, 7, workspace, 7"   "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod, 8, workspace, 8"   "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod, 9, workspace, 9"   "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod, 0, workspace, 10"  "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshots
        ", Print,      exec, hyprshot -m region --clipboard-only"
        "SHIFT, Print, exec, hyprshot -m output --output-folder ~/Pictures/Screenshots"

        # Media keys
        ", XF86AudioPlay,        exec, playerctl play-pause"
        ", XF86AudioPause,       exec, playerctl play-pause"
        ", XF86AudioNext,        exec, playerctl next"
        ", XF86AudioPrev,        exec, playerctl previous"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Gaomon M10K touch dial → volume
      # In otd-gui: set dial output type to "Scroll" → XF86AudioRaise/LowerVolume
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ];

      exec-once = [
        "waybar"
        "udiskie --tray"
        # wlsunset: day 06:30–18:30 at 6500K, night 18:30–06:30 at 2700K
        "bash -c 'sleep 3 && wlsunset -S 06:30 -s 18:30 -T 6500 -t 2700'"
      ];
    };
  };

  # ── Waybar ────────────────────────────────────────────────────────────────────
  # Colours reference config.lib.stylix.colors — update with the scheme automatically.
  # stylix.targets.waybar is disabled so we own the full CSS.
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer    = "bottom";
      position = "top";
      height   = 20;
      spacing  = 0;

      modules-left   = [ "hyprland/workspaces" ];
      modules-center = [ "hyprland/window" ];
      modules-right  = [ "custom/pipewire" "clock" ];

      "hyprland/workspaces" = { format = "{id}"; on-click = "activate"; tooltip = false; };
      "hyprland/window"     = { format = "{}"; max-length = 50; tooltip = false; };
      clock                 = { format = "{:%H:%M}"; tooltip = false; };

      "custom/pipewire" = {
        exec           = ''wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk 'NF{if ($3=="[MUTED]") print "MUTE"; else print "VOL " int($2*100) "%"}' '';
        interval       = 1;
        on-click       = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up   = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        tooltip        = false;
      };
    };

    style = with config.lib.stylix.colors; ''
      * { border: none; border-radius: 0; font-family: "Hack Nerd Font Mono"; font-size: 12px; min-height: 0; }
      window#waybar                { background-color: #${base00}; color: #${base05}; }
      #workspaces button           { padding: 0 8px; background-color: #${base01}; color: #${base05}; margin: 0 2px; }
      #workspaces button.active    { background-color: #${base05}; color: #${base00}; }
      #workspaces button.urgent    { background-color: #${base08}; color: #${base07}; }
      #window                      { padding: 0 10px; background-color: #${base00}; color: #${base05}; }
      #clock, #custom-pipewire     { padding: 0 10px; background-color: #${base00}; color: #${base05}; }
      #clock:hover,
      #custom-pipewire:hover       { background-color: #${base01}; }
      #custom-pipewire             { color: #${base04}; }
    '';
  };

  # ── Foot terminal ─────────────────────────────────────────────────────────────
  # Colors, font, and dpi-aware set by stylix.targets.foot
  programs.foot = {
    enable   = true;
    settings = {
      main  = { term = "xterm-256color"; };
      mouse = { hide-when-typing = "yes"; };
      tweak = { sixel = "yes"; };
    };
  };

  # ── Stylix targets ────────────────────────────────────────────────────────────
  stylix.targets = {
    waybar.enable    = false;  # CSS managed manually above
    hyprland.enable  = false;  # borders managed manually above
    librewolf.enable = false;  # unthemed — browser uses its own default appearance
    gtk.enable       = true;
    qt.enable        = true;
    fuzzel.enable    = true;
    foot.enable      = true;
  };
}
