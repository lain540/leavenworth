{ config, pkgs, inputs, ... }:

{
  # Desktop packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    wlr-randr
    
    # Screenshots
    grim
    slurp
    
    # Launcher
    bemenu
    
    # Audio control (pipewire native)
    wireplumber
  ];

  # GTK theme
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
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
  };

  # Qt theme to match GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # Hyprland configuration - minimal
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    settings = {
      # Monitors - commented out for VM testing
      # Uncomment and adjust for real hardware
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

      # General settings - minimal
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        "col.active_border" = "rgba(ffffffff)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration - disabled for minimal look
      decoration = {
        rounding = 0;
        blur = {
          enabled = false;
        };
        drop_shadow = {
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
        "$mod, D, exec, bemenu-run"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, foot nnn"
        "$mod, V, togglefloating"
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

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Waybar - status bar
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ ];
        modules-right = [ "custom/pipewire" "clock" ];

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
        };

        clock = {
          format = "{:%H:%M}";
        };

        "custom/pipewire" = {
          exec = "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3 == \"[MUTED]\") print \"MUTE\"; else print \"VOL \" int($2 * 100) \"%\"}'";
          interval = 1;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
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
          color: #d8d8d8;
      }

      #clock,
      #custom-pipewire {
          padding: 0 10px;
          color: #d8d8d8;
      }

      #custom-pipewire {
          color: #b8b8b8;
      }
    '';
  };

  # Dunst notification daemon - minimal base16 colors
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 0;
        frame_color = "#ffffff";
        font = "Hack Nerd Font Mono 10";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        max_icon_size = 32;
        sticky_history = true;
        history_length = 20;
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
      };

      urgency_low = {
        background = "#181818";
        foreground = "#b8b8b8";
        timeout = 5;
      };

      urgency_normal = {
        background = "#181818";
        foreground = "#d8d8d8";
        timeout = 10;
      };

      urgency_critical = {
        background = "#ab4642";
        foreground = "#f8f8f8";
        frame_color = "#ab4642";
        timeout = 0;
      };
    };
  };

  # wlsunset - blue light filter as a service
  services.wlsunset = {
    enable = true;
    latitude = "63.8";
    longitude = "20.3";
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
    };
  };
}
