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
    papirus-icon-theme
  ];

  # ── Cursor — system pointer theme ────────────────────────────────────────────
  # home.pointerCursor propagates the cursor to all Wayland clients and GTK apps.
  # stylix.cursor in configuration.nix sets it at the system level (greetd etc).
  # Both need to agree on the same theme or you get mixed cursors.
  home.pointerCursor = {
    gtk.enable = true;
    package    = pkgs.adwaita-icon-theme;
    name       = "Adwaita";
    size       = 24;
  };

  # ── GTK icon theme ────────────────────────────────────────────────────────────
  gtk = {
    enable    = true;
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk4.extraConfig.gtk-decoration-layout = "";
    gtk3.extraConfig.gtk-decoration-layout = "";
  };

  # ── Yazi — default file manager ───────────────────────────────────────────────
  # Associates inode/directory and common archive types with yazi so that apps
  # (file pickers, terminal openers, etc.) know to launch it.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"         = "yazi.desktop";
      "application/zip"         = "yazi.desktop";
      "application/x-tar"       = "yazi.desktop";
      "application/x-bzip2"     = "yazi.desktop";
      "application/x-gzip"      = "yazi.desktop";
      "application/x-xz"        = "yazi.desktop";
      "application/x-zstd"      = "yazi.desktop";
      "application/x-rar"       = "yazi.desktop";
      "application/x-7z-compressed" = "yazi.desktop";
    };
  };

  # ── Fuzzel launcher ───────────────────────────────────────────────────────────
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        lines         = 10;
        width         = 40;
        terminal      = "foot";
        icons-enabled = false;
        # font set by stylix.targets.fuzzel
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
        # Cursor — must match stylix.cursor.name in configuration.nix
        "XCURSOR_THEME,Adwaita"
        "XCURSOR_SIZE,24"
        # Editor
        "EDITOR,nvim"
        "VISUAL,nvim"
        # Mozilla Wayland
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_GTK_TITLEBAR_DECORATION,client"
        # Qt
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        # Default file manager — apps that respect XDG_CURRENT_DESKTOP pick this up
        "FILE_MANAGER,yazi"
      ];

      general = {
        gaps_in     = 0;
        gaps_out    = 0;
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

        "$mod, Space, exec, hyprctl switchxkblayout all next"

        "$mod, y,     movefocus, l"
        "$mod, n,     movefocus, d"
        "$mod, e,     movefocus, u"
        "$mod, o,     movefocus, r"
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod SHIFT, y,     movewindow, l"
        "$mod SHIFT, n,     movewindow, d"
        "$mod SHIFT, e,     movewindow, u"
        "$mod SHIFT, o,     movewindow, r"
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

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

        ", Print,      exec, hyprshot -m region --clipboard-only"
        "SHIFT, Print, exec, hyprshot -m output --output-folder ~/Pictures/Screenshots"

        "$mod, a, exec, qpwgraph"

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

      # ── Gaomon M10K touch dial → volume ───────────────────────────────────────
      # The touch strip/dial is exposed as scroll events on the tablet device.
      # These binds catch scroll events from any device and route them to volume.
      # If you want ONLY the tablet dial to control volume (not mouse wheel), you
      # can scope these to the tablet device name via `bindle` with a device filter.
      # Map the dial in otd-gui to "Scroll" output type for this to work.
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ];

      exec-once = [
        "waybar"
        "udiskie --tray"

        # ── wlsunset — fixed schedule blue light filter ────────────────────────
        # Uses explicit times instead of GPS location for predictable behaviour.
        #
        # Flags:
        #   -S HH:MM  sunrise  — when to start transitioning TO day temperature
        #   -s HH:MM  sunset   — when to start transitioning TO night temperature
        #   -T        day colour temperature  (6500K = neutral / slightly cool)
        #   -t        night colour temperature (2700K = very warm amber)
        #
        # 2700K at night is quite obvious — screens go clearly orange.
        # Raise -t toward 4000K if you want a subtler effect.
        #
        # Schedule: day 06:30–18:30 / night 18:30–06:30
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
  programs.foot = {
    enable = true;
    settings = {
      main.term            = "xterm-256color";
      mouse.hide-when-typing = "yes";
      tweak.sixel          = "yes";
      # font, dpi-aware, and colors are all set by stylix.targets.foot
    };
  };

  # ── Stylix targets ────────────────────────────────────────────────────────────
  stylix.targets = {
    waybar.enable    = false;  # CSS managed manually above with stylix color refs
    hyprland.enable  = false;  # borders set manually via config.lib.stylix.colors
    gtk.enable       = true;
    qt.enable        = true;
    fuzzel.enable    = true;
    foot.enable      = true;
    # librewolf — stylix writes userChrome.css/userContent.css which is separate
    # from programs.librewolf.settings (user.js) — no conflict, enable theming
    librewolf.enable = true;
    # swaybg — no image is set so there is nothing to display; keep disabled
    #swaybg.enable    = false;
  };
}
