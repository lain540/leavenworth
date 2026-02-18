{ config, pkgs, inputs, ... }:

{
  # ── Desktop packages ─────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    wl-clipboard
    wlr-randr
    hyprshot
    wireplumber
    playerctl
    wlsunset
    papirus-icon-theme  # icon theme (stylix doesn't manage icons)
  ];

  # ── GTK icon theme ────────────────────────────────────────────────────────────
  # Stylix owns gtk.theme, gtk.font, and gtk.cursorTheme.
  # Icon theme is not touched by stylix, so we set it here independently.
  gtk = {
    enable    = true;
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    # Disable window decoration buttons (close/min/max) for all GTK apps
    gtk4.extraConfig.gtk-decoration-layout = "";
    gtk3.extraConfig.gtk-decoration-layout = "";
  };

  # ── Fuzzel launcher ───────────────────────────────────────────────────────────
  # Colors are handled by stylix (stylix.targets.fuzzel enabled below).
  # Only layout/behaviour settings live here.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font          = "Hack Nerd Font Mono:size=12";
        lines         = 10;
        width         = 40;
        terminal      = "foot";
        icons-enabled = false;
      };
      border = {
        width  = 1;
        radius = 0;
      };
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable          = true;
    xwayland.enable = true;

    settings = {
      # ── Monitors ──────────────────────────────────────────────────────────────
      # Real hardware — dual monitor setup:
      #   HDMI-A-1: 3440x1440 ultrawide (primary, bottom), 1.25× scaling
      #   DP-1:     1920x1080 (secondary, centred above the ultrawide)
      #     x offset = (2752 − 1920) / 2 = 416
      monitor = [
        "HDMI-A-1,3440x1440@60,0x1080,1.25"
        "DP-1,1920x1080@60,416x0,1"
      ];
      # VirtualBox — comment out real monitors above and uncomment:
      # monitor = [
      #   "Virtual-1,1920x1080@60,0x0,1"
      # ];

      # ── Input ─────────────────────────────────────────────────────────────────
      input = {
        kb_layout  = "us,se";
        kb_variant = "workman,";
        kb_options = "";
        follow_mouse            = 1;
        touchpad.natural_scroll = false;
        sensitivity             = 0;
      };

      cursor.no_hardware_cursors = true;

      env = [
        # Cursor
        "XCURSOR_SIZE,16"
        # Editor
        "EDITOR,nvim"
        "VISUAL,nvim"
        # Wayland for Mozilla apps
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_GTK_TITLEBAR_DECORATION,client"
        # Qt scaling
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        # GTK_THEME, QT_QPA_PLATFORMTHEME, QT_STYLE_OVERRIDE are set by stylix
      ];

      # ── Borders — pull colours from the active stylix scheme ──────────────────
      # base05 = foreground (active), base03 = comment/inactive
      # Changing stylix.base16Scheme in configuration.nix updates these automatically.
      general = {
        gaps_in    = 0;
        gaps_out   = 0;
        border_size = 2;
        "col.active_border"   = "rgba(${config.lib.stylix.colors.base05}ff)";
        "col.inactive_border" = "rgba(${config.lib.stylix.colors.base03}aa)";
        layout = "dwindle";
      };

      misc = {
        disable_hyprland_logo    = true;
        disable_splash_rendering = true;
      };

      decoration = {
        rounding       = 0;
        blur.enabled   = false;
        shadow.enabled = false;
      };

      animations.enabled = false;

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      # ── Keybindings ───────────────────────────────────────────────────────────
      # Workman layout: Y N E O  =  physical H J K L
      "$mod" = "SUPER";

      bind = [
        "$mod, Return,  exec, foot"
        "$mod, d,       exec, fuzzel"
        "$mod, w,       exec, foot -e yazi"
        "$mod, q,       killactive"
        "$mod SHIFT, q, exit"
        "$mod, f,       fullscreen"
        "$mod, t,       togglefloating"
        "$mod, s,       togglesplit"
        "$mod, p,       pseudo"

        # Keyboard layout switch (us/workman ↔ se)
        "$mod, Space, exec, hyprctl switchxkblayout all next"

        # Focus
        "$mod, y,     movefocus, l"
        "$mod, n,     movefocus, d"
        "$mod, e,     movefocus, u"
        "$mod, o,     movefocus, r"
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        # Move windows
        "$mod SHIFT, y,     movewindow, l"
        "$mod SHIFT, n,     movewindow, d"
        "$mod SHIFT, e,     movewindow, u"
        "$mod SHIFT, o,     movewindow, r"
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshots
        ", Print,      exec, hyprshot -m region --clipboard-only"
        "SHIFT, Print, exec, hyprshot -m output --output-folder ~/Pictures/Screenshots"

        # Audio
        "$mod, a, exec, qpwgraph"

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

      exec-once = [
        "waybar"
        "udiskie --tray"
        # wlsunset — 59.3°N 18.1°E = Stockholm
        # Brief delay so Hyprland finishes registering outputs before gamma is set
        "bash -c 'sleep 3 && wlsunset -l 59.3 -L 18.1 -t 3500 -T 6500'"
      ];
    };
  };

  # ── Waybar ────────────────────────────────────────────────────────────────────
  # Colors reference config.lib.stylix.colors so they update with the scheme.
  # stylix.targets.waybar is disabled below — we own the full CSS here.
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

      "hyprland/workspaces" = {
        format   = "{id}";
        on-click = "activate";
        tooltip  = false;
      };

      "hyprland/window" = {
        format     = "{}";
        max-length = 50;
        tooltip    = false;
      };

      clock = {
        format  = "{:%H:%M}";
        tooltip = false;
      };

      "custom/pipewire" = {
        exec           = ''wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk 'NF{if ($3=="[MUTED]") print "MUTE"; else print "VOL " int($2*100) "%"}' '';
        interval       = 1;
        on-click       = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up   = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        tooltip        = false;
      };
    };

    # All hex values come from config.lib.stylix.colors — change the scheme in
    # configuration.nix and the bar recolors on the next rebuild automatically.
    style = with config.lib.stylix.colors; ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Hack Nerd Font Mono";
          font-size: 12px;
          min-height: 0;
      }
      window#waybar {
          background-color: #${base00};
          color:            #${base05};
      }
      #workspaces button {
          padding:          0 8px;
          background-color: #${base01};
          color:            #${base05};
          margin:           0 2px;
      }
      #workspaces button.active {
          background-color: #${base05};
          color:            #${base00};
      }
      #workspaces button.urgent {
          background-color: #${base08};
          color:            #${base07};
      }
      #window {
          padding:          0 10px;
          background-color: #${base00};
          color:            #${base05};
      }
      #clock,
      #custom-pipewire {
          padding:          0 10px;
          background-color: #${base00};
          color:            #${base05};
      }
      #clock:hover,
      #custom-pipewire:hover {
          background-color: #${base01};
      }
      #custom-pipewire {
          color: #${base04};
      }
    '';
  };

  # ── Foot terminal ──────────────────────────────────────────────────────────────
  # Colors managed by stylix (stylix.targets.foot enabled below).
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term      = "xterm-256color";
        font      = "Hack Nerd Font Mono:size=11";
        dpi-aware = "yes";
      };
      mouse.hide-when-typing = "yes";
      tweak.sixel = "yes";  # image previews in yazi
    };
  };

  # ── Stylix targets ────────────────────────────────────────────────────────────
  # Enable everything we want stylix to own.
  # Disable only waybar — we write the CSS ourselves using stylix color refs above
  # so colors still update when you change the scheme.
  stylix.targets = {
    waybar.enable   = false;  # we handle CSS manually with config.lib.stylix.colors
    hyprland.enable = false;  # we set borders manually via config.lib.stylix.colors in general{} above
    gtk.enable      = true;
    qt.enable       = true;
    fuzzel.enable   = true;
    foot.enable     = true;
  };
}
