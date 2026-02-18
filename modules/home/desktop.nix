{ config, pkgs, inputs, ... }:

{
  # Desktop packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    wlr-randr

    # Screenshots
    hyprshot

    # Audio control (pipewire native)
    wireplumber

    # Media control
    playerctl

    # Blue light filter (launched via exec-once, not as a systemd service)
    wlsunset
  ];

  # fuzzel application launcher - base16-default-dark theme
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font Mono:size=12";
        lines = 10;
        width = 40;
        terminal = "foot";
        icons-enabled = false;
      };
      colors = {
        background      = "181818ff";
        text            = "d8d8d8ff";
        match           = "f7ca88ff";
        selection       = "383838ff";
        selection-text  = "f8f8f8ff";
        selection-match = "f7ca88ff";
        counter         = "585858ff";
        border          = "585858ff";
      };
      border = {
        width  = 1;
        radius = 0;
      };
    };
  };

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name    = "Materia-dark";
      package = pkgs.materia-theme;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Hack Nerd Font Mono";
      size = 11;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "";
    };
    gtk3.extraConfig = {
      gtk-decoration-layout = "";
    };
  };

  # Qt theme
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name    = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE    = "adwaita-dark";
  };

  # ── Hyprland ────────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable         = true;
    xwayland.enable = true;

    settings = {
      # ── Monitors ────────────────────────────────────────────────────────────
      # Real hardware — dual monitor setup:
      #   HDMI-A-1: 3440x1440 ultrawide (primary, bottom), 1.25x scaling
      #   DP-1:     1920x1080 (secondary, centered above the ultrawide)
      #
      # DP-1 is centered above HDMI-A-1:
      #   x offset = (2752 - 1920) / 2 = 416
      monitor = [
        "HDMI-A-1,3440x1440@60,0x1080,1.25"
        "DP-1,1920x1080@60,416x0,1"
      ];
      # VirtualBox — comment out the real monitors above and uncomment this:
      # monitor = [
      #   "Virtual-1,1920x1080@60,0x0,1"
      # ];

      # ── Input ───────────────────────────────────────────────────────────────
      input = {
        kb_layout  = "us,se";
        kb_variant = "workman,";
        kb_options = "";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
        sensitivity = 0;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      env = [
        "XCURSOR_THEME,Adwaita"
        "XCURSOR_SIZE,16"
        "EDITOR,nvim"
        "VISUAL,nvim"
        "GTK_THEME,Materia-dark:dark"
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_GTK_TITLEBAR_DECORATION,client"
        "QT_QPA_PLATFORMTHEME,gtk2"
        "QT_STYLE_OVERRIDE,adwaita-dark"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      ];

      # ── General — minimal / DWM-esque ───────────────────────────────────────
      general = {
        gaps_in    = 0;
        gaps_out   = 0;
        border_size = 2;
        "col.active_border"   = "rgba(ffffffff)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      misc = {
        disable_hyprland_logo    = true;
        disable_splash_rendering = true;
      };

      decoration = {
        rounding = 0;
        blur.enabled   = false;
        shadow.enabled = false;
      };

      animations.enabled = false;

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      # ── Keybindings ─────────────────────────────────────────────────────────
      # Workman physical key reference (produced keysym → physical key):
      #   Y N E O  =  H J K L  (vi navigation, home row right hand)
      "$mod" = "SUPER";

      bind = [
        # Applications
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
        "$mod, Space,   exec, hyprctl switchxkblayout all next"

        # Focus — YNEO = physical HJKL on Workman
        "$mod, y,    movefocus, l"
        "$mod, n,    movefocus, d"
        "$mod, e,    movefocus, u"
        "$mod, o,    movefocus, r"
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

        # ── Screenshots ────────────────────────────────────────────────────────
        # Area capture → clipboard only (no file saved)
        ", Print,      exec, hyprshot -m region --clipboard-only"
        # Full output → save to Screenshots folder
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
        # wlsunset: 59.3°N 18.1°E = Stockholm
        # Update coordinates if you move. Gradients between -t (night) and -T (day) colour temp.
        "bash -c 'sleep 3 && wlsunset -l 59.3 -L 18.1 -t 3500 -T 6500'"
      ];
    };
  };

  # ── Waybar ──────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
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
          exec       = ''wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk 'NF{if ($3=="[MUTED]") print "MUTE"; else print "VOL " int($2*100) "%"}' '';
          interval   = 1;
          on-click   = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up   = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          tooltip    = false;
        };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Hack Nerd Font Mono";
          font-size: 12px;
          min-height: 0;
      }
      window#waybar {
          background-color: #181818;
          color: #d8d8d8;
      }
      #workspaces button {
          padding: 0 8px;
          background-color: #282828;
          color: #d8d8d8;
          margin: 0 2px;
      }
      #workspaces button.active {
          background-color: #d8d8d8;
          color: #181818;
      }
      #workspaces button.urgent {
          background-color: #ab4642;
          color: #f8f8f8;
      }
      #window {
          padding: 0 10px;
          background-color: #181818;
          color: #d8d8d8;
      }
      #clock, #custom-pipewire {
          padding: 0 10px;
          background-color: #181818;
          color: #d8d8d8;
      }
      #clock:hover, #custom-pipewire:hover {
          background-color: #282828;
      }
      #custom-pipewire {
          color: #b8b8b8;
      }
    '';
  };

  # ── Foot terminal ────────────────────────────────────────────────────────────
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term      = "xterm-256color";
        font      = "Hack Nerd Font Mono:size=11";
        dpi-aware = "yes";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      colors = {
        alpha      = 1.0;
        background = "181818";
        foreground = "d8d8d8";
      };
      tweak = {
        sixel = "yes";  # image previews in yazi
      };
    };
  };
}
