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
        # No icons for minimal look
        icons-enabled = false;
      };
      colors = {
        # base16-default-dark - all values are RRGGBBAA format
        background     = "181818ff"; # base00 - background
        text           = "d8d8d8ff"; # base05 - foreground
        match          = "f7ca88ff"; # base0A - yellow (matched chars)
        selection      = "383838ff"; # base02 - selection bg
        selection-text = "f8f8f8ff"; # base07 - selection fg
        selection-match= "f7ca88ff"; # base0A - matched chars in selection
        counter        = "585858ff"; # base03 - counter text
        border         = "585858ff"; # base03 - border
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
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    
    font = {
      name = "Hack Nerd Font Mono";
      size = 11;
    };
    
    # GTK4 dark mode and disable window decorations (titlebars)
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "";  # Removes close/minimize/maximize buttons
    };

    gtk3.extraConfig = {
      gtk-decoration-layout = "";  # Also disable for GTK3 apps
    };
  };

  # Qt theme to match GTK - dark mode
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Force Qt dark mode via environment
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # Hyprland configuration - minimal
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    settings = {
      # Monitors
      monitor = [
         "DP-1,3440x1440@60,0x1080,1"
         "HDMI-A-1,1920x1080@60,760x0,1"
       ];

      # Input configuration
      input = {
        kb_layout = "us,se";
        kb_variant = "workman,";
        # No grp toggle here - layout switch is handled by $mod+Space bind below
        # so it shows up as an intentional action rather than an accidental keystroke
        kb_options = "";

        follow_mouse = 1;
        touchpad.natural_scroll = false;
        sensitivity = 0;
      };

      # Cursor theme
      cursor = {
        no_hardware_cursors = true;
      };
      
      env = [
        "XCURSOR_THEME,Adwaita"
        "XCURSOR_SIZE,16"
        # Set default editor
        "EDITOR,nvim"
        "VISUAL,nvim"
        # GTK theme - forces GTK apps including LibreWolf to use Materia dark
        "GTK_THEME,Materia-dark:dark"
        # Mozilla Wayland support and theme
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_GTK_TITLEBAR_DECORATION,client"
        # Qt dark mode
        "QT_QPA_PLATFORMTHEME,gtk2"
        "QT_STYLE_OVERRIDE,adwaita-dark"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      ];

      # General settings - minimal
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        "col.active_border" = "rgba(ffffffff)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Disable splash
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      # Decoration - disabled for minimal look
      decoration = {
        rounding = 0;
        blur = {
          enabled = false;
        };
        shadow = {
          enabled = false;
        };
      };

      # Animations - disabled
      animations = {
        enabled = false;
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Keybindings - optimized for Workman keyboard layout
      # ─────────────────────────────────────────────────────
      # Workman physical key → produced keysym reference:
      #   Physical HJKL → Y N E O  (used for navigation, same finger positions as vim)
      #   Physical QWERTY rows:
      #     Q D R W B J F U P ;     (top row)
      #     A S H T G Y N E O I     (home row)
      #     Z X M C V K L , . /     (bottom row)
      "$mod" = "SUPER";

      bind = [
        # ── Applications ───────────────────────────────────────────────
        "$mod, Return,  exec, foot"              # Terminal (Return = universal)
        "$mod, d,       exec, fuzzel"            # Launcher       (physical W, top row)
        "$mod, w,       exec, foot -e yazi"      # Files          (physical R, top row)
        "$mod, q,       killactive"              # Close window   (physical Q, easy reach, mnemonic quit)
        "$mod SHIFT, q, exit"                    # Exit Hyprland  (shift guard to avoid accidents)
        "$mod, f,       fullscreen"              # Fullscreen     (physical U, mnemonic full)
        "$mod, t,       togglefloating"          # Float toggle   (physical F, mnemonic tile/float)
        "$mod, s,       togglesplit"             # Toggle split   (physical S, home row)
        "$mod, p,       pseudo"                  # Pseudo tile    (physical O)

        # ── Keyboard layout switch ─────────────────────────────────────
        # Cycles through us/workman and se layouts
        "$mod, Space,   exec, hyprctl switchxkblayout all next"

        # ── Focus - YNEO = physical HJKL (vi-style on Workman) ─────────
        "$mod, y,       movefocus, l"            # physical H
        "$mod, n,       movefocus, d"            # physical J
        "$mod, e,       movefocus, u"            # physical K
        "$mod, o,       movefocus, r"            # physical L
        # Arrow keys kept as fallback
        "$mod, left,    movefocus, l"
        "$mod, right,   movefocus, r"
        "$mod, up,      movefocus, u"
        "$mod, down,    movefocus, d"

        # ── Move windows - SHIFT + YNEO ────────────────────────────────
        "$mod SHIFT, y, movewindow, l"
        "$mod SHIFT, n, movewindow, d"
        "$mod SHIFT, e, movewindow, u"
        "$mod SHIFT, o, movewindow, r"
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        # ── Workspaces ─────────────────────────────────────────────────
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

        # ── Move window to workspace ────────────────────────────────────
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

        # ── Screenshots ────────────────────────────────────────────────
        ", Print,       exec, hyprshot -m region --output-folder ~/Pictures/Screenshots"
        "SHIFT, Print,  exec, hyprshot -m output --output-folder ~/Pictures/Screenshots"

        # ── Audio ──────────────────────────────────────────────────────
        # Physical A = A in Workman (home row, left hand)
        "$mod, a,       exec, foot -e sh -c 'wpctl status | grep -A 50 Audio && echo && read -p \"Enter sink ID to switch: \" sink && wpctl set-default $sink'"

        # Media keys
        ", XF86AudioPlay,        exec, playerctl play-pause"
        ", XF86AudioPause,       exec, playerctl play-pause"
        ", XF86AudioNext,        exec, playerctl next"
        ", XF86AudioPrev,        exec, playerctl previous"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Autostart
      exec-once = [
        "waybar"
        "udiskie --tray"   # Auto-mount removable drives and phones
      ];
    };
  };

  # Waybar - status bar
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "bottom";
        position = "top";
        height = 20;
        spacing = 0;
        
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "custom/pipewire" "clock" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          tooltip = false;
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M}";
          tooltip = false;
        };

        "custom/pipewire" = {
          # Poll every second with a script that retries until a sink exists.
          # This handles the race between waybar starting and wireplumber
          # enumerating sinks - the module will show as soon as audio is ready.
          exec = ''wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk 'NF{if ($3=="[MUTED]") print "MUTE"; else print "VOL " int($2*100) "%"}' '';
          interval = 1;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          tooltip = false;
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

      #clock,
      #custom-pipewire {
          padding: 0 10px;
          background-color: #181818;
          color: #d8d8d8;
      }

      #clock:hover,
      #custom-pipewire:hover {
          background-color: #282828;
      }

      #custom-pipewire {
          color: #b8b8b8;
      }
    '';
  };

  # wlsunset - blue light filter with custom times
  # Daylight: 6:30 - 18:00, Night: 18:00 - 6:30
  services.wlsunset = {
    enable = true;
    sunrise = "06:30";
    sunset = "18:00";
    temperature = {
      day = 6500;
      night = 3500;
    };
  };

  # Foot terminal - minimal with Hack Nerd Font
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Hack Nerd Font Mono:size=11";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        alpha = 1.0;
        background = "181818";
        foreground = "d8d8d8";
      };

      # Enable sixel for yazi image previews
      tweak = {
        sixel = "yes";
      };
    };
  };
}
