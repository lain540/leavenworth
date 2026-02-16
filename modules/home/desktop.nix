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
    
    # Media control
    playerctl
    
    # Media player for testing
    mpv
    
    # bemenu wrapper with base16 colors (avoids # comment issues in Hyprland)
    (pkgs.writeShellScriptBin "bemenu-themed" ''
      #!/usr/bin/env bash
      bemenu-run -H 20 \
        --fn 'Hack Nerd Font Mono 12' \
        --tb '#181818' --tf '#d8d8d8' \
        --fb '#181818' --ff '#d8d8d8' \
        --nb '#181818' --nf '#d8d8d8' \
        --hb '#d8d8d8' --hf '#181818' \
        --sb '#383838' --sf '#d8d8d8' \
        --scb '#181818' --scf '#d8d8d8'
    '')
    
    # nnn opener script - opens text files in nvim
    (pkgs.writeShellScriptBin "nnn-open" ''
      #!/usr/bin/env bash
      
      # Get mime type
      MIME=$(file --brief --mime-type "$1")
      
      # Open text files and common code files in nvim
      case "$MIME" in
        text/*|application/json|application/x-shellscript|application/javascript)
          foot -e nvim "$1"
          ;;
        inode/directory)
          ;;
        *)
          xdg-open "$1" 2>/dev/null
          ;;
      esac
    '')
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
        # nnn configuration - use custom opener script
        "NNN_OPENER,nnn-open"
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
        "$mod, D, exec, bemenu-themed"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, foot nnn"
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

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        
        # Audio output switcher
        "$mod, A, exec, foot -e sh -c 'wpctl status | grep -A 50 Audio && echo && read -p \"Enter sink ID to switch: \" sink && wpctl set-default $sink'"
        
        # Media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Autostart
      exec-once = [
        "waybar"
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

      #workspaces button:hover {
          background-color: #383838;
          color: #d8d8d8;
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
    };
  };
}
