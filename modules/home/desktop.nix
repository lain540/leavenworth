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
      # VirtualBox - comment out when running on real hardware
      monitor = [
        "Virtual-1,1920x1080@60,0x0,1"
      ];
      # Real hardware monitors - uncomment when running on real hardware
      # monitor = [
      #   "DP-1,3440x1440@144,0x1080,1"
      #   "HDMI-A-1,1920x1080@60,760x0,1"
      # ];

      # Input configuration
      input = {
        kb_layout = "us,se";
        kb_variant = "workman,";
        kb_options = "grp:alt_shift_toggle";
        
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

      # Keybindings
      "$mod" = "SUPER";
      
      bind = [
        # Applications
        "$mod, Return, exec, foot"
        "$mod, D, exec, fuzzel"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, foot -e yazi"
        "$mod, V, togglefloating"
        "$mod, F, fullscreen"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"

        # Focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

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

        # Move to workspace
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

        # Screenshots - save to ~/Pictures/Screenshots/
        ", Print, exec, hyprshot -m region --output-folder ~/Pictures/Screenshots"
        "SHIFT, Print, exec, hyprshot -m output --output-folder ~/Pictures/Screenshots"
        
        # Audio output switcher
        "$mod, A, exec, foot -e sh -c 'wpctl status | grep -A 50 Audio && echo && read -p \"Enter sink ID to switch: \" sink && wpctl set-default $sink && pkill -RTMIN+8 waybar'"
        
        # Media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ && pkill -RTMIN+8 waybar"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && pkill -RTMIN+8 waybar"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && pkill -RTMIN+8 waybar"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Autostart
      exec-once = [
        # Wait for pipewire to fully initialize then start waybar and signal audio
        # The sleep gives pipewire/wireplumber time to enumerate sinks before
        # the waybar volume module runs its first wpctl query
        "bash -c 'sleep 2 && waybar & sleep 1 && pkill -RTMIN+8 waybar'"
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
          exec = "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3 == \"[MUTED]\") print \"MUTE\"; else print \"VOL \" int($2 * 100) \"%\"}'";
          interval = "once";
          signal = 8;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && pkill -RTMIN+8 waybar";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ && pkill -RTMIN+8 waybar";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- && pkill -RTMIN+8 waybar";
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
