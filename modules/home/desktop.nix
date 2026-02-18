{ config, pkgs, inputs, ... }:

{
  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard wlr-randr hyprshot

    # Audio / media control
    wireplumber playerctl

    # Blue light filter
    wlsunset
  ];

  # ── GTK ───────────────────────────────────────────────────────────────────────
  # stylix owns gtk.theme, gtk.font, gtk.cursorTheme — only icons live here.
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
      "inode/directory"             = "yazi.desktop";
      "application/zip"             = "yazi.desktop";
      "application/x-tar"           = "yazi.desktop";
      "application/x-bzip2"         = "yazi.desktop";
      "application/x-gzip"          = "yazi.desktop";
      "application/x-xz"            = "yazi.desktop";
      "application/x-zstd"          = "yazi.desktop";
      "application/x-rar"           = "yazi.desktop";
      "application/x-7z-compressed" = "yazi.desktop";
    };
  };

  # ── Fuzzel launcher ───────────────────────────────────────────────────────────
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
      # ── Monitors ────────────────────────────────────────────────────────────
      # Ultrawide primary (bottom), 1080p secondary (centred above).
      # DP-1 x-offset = (3440 - 1920) / 2 = 760
      monitor = [
        "HDMI-A-1,3440x1440@60,0x1080,1"
        "DP-1,1920x1080@60,760x0,1"
      ];

      # Pin workspaces so the ultrawide always owns 1–9, DP-1 owns 10.
      # Without this Hyprland assigns workspace 1 to whichever output it
      # initialises first, which may be DP-1.
      workspace = [
        "1,  monitor:HDMI-A-1, default:true"
        "2,  monitor:HDMI-A-1"
        "3,  monitor:HDMI-A-1"
        "4,  monitor:HDMI-A-1"
        "5,  monitor:HDMI-A-1"
        "6,  monitor:HDMI-A-1"
        "7,  monitor:HDMI-A-1"
        "8,  monitor:HDMI-A-1"
        "9,  monitor:HDMI-A-1"
        "10, monitor:DP-1, default:true"
      ];

      # ── Input ───────────────────────────────────────────────────────────────
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
        # Cursor
        "XCURSOR_THEME,Adwaita" "XCURSOR_SIZE,24"

        # Editor
        "EDITOR,nvim" "VISUAL,nvim"

        # Mozilla native Wayland
        "MOZ_ENABLE_WAYLAND,1" "MOZ_GTK_TITLEBAR_DECORATION,client"

        # Qt
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"

        # File manager
        "FILE_MANAGER,yazi"

        # XWayland scaling — tell XWayland apps not to scale themselves
        # (avoids blurry/doubled scaling on the native-resolution ultrawide)
        "XCURSOR_SIZE,24"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
      ];

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

        # Layout switch us/workman ↔ se
        "$mod, Space, exec, hyprctl switchxkblayout all next"

        # Focus (Workman: Y N E O = H J K L)
        "$mod, y, movefocus, l"  "$mod, n, movefocus, d"
        "$mod, e, movefocus, u"  "$mod, o, movefocus, r"
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

        # Media keys (keyboard hardware buttons)
        ", XF86AudioPlay,        exec, playerctl play-pause"
        ", XF86AudioPause,       exec, playerctl play-pause"
        ", XF86AudioNext,        exec, playerctl next"
        ", XF86AudioPrev,        exec, playerctl previous"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # bindel — repeatable binds for volume (keyboard keys + tablet dial).
      # The tablet dial sends XF86AudioRaise/LowerVolume via OTD.
      # In otd-gui: Bindings → set dial to output type "Key" →
      #   clockwise = XF86AudioRaiseVolume, counter = XF86AudioLowerVolume.
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ];

      exec-once = [
        "waybar"
        "udiskie --tray"
        # wlsunset: day 06:30–18:30 at 6500K, night at 2700K
        "bash -c 'sleep 3 && wlsunset -S 06:30 -s 18:30 -T 6500 -t 2700'"
      ];
    };
  };

  # ── Waybar ────────────────────────────────────────────────────────────────────
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
      window#waybar             { background-color: #${base00}; color: #${base05}; }
      #workspaces button        { padding: 0 8px; background-color: #${base01}; color: #${base05}; margin: 0 2px; }
      #workspaces button.active { background-color: #${base05}; color: #${base00}; }
      #workspaces button.urgent { background-color: #${base08}; color: #${base07}; }
      #window                   { padding: 0 10px; background-color: #${base00}; color: #${base05}; }
      #clock, #custom-pipewire  { padding: 0 10px; background-color: #${base00}; color: #${base05}; }
      #clock:hover, #custom-pipewire:hover { background-color: #${base01}; }
      #custom-pipewire          { color: #${base04}; }
    '';
  };

  # ── Foot terminal ─────────────────────────────────────────────────────────────
  # Colors, font, dpi-aware set by stylix.targets.foot
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
    librewolf.enable = false;
    gtk.enable       = true;
    qt.enable        = true;
    fuzzel.enable    = true;
    foot.enable      = true;
  };
}
