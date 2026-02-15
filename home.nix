{ config, pkgs, inputs, ... }:

{
  home.username = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep fd fzf
    eww
    pamixer
    socat
    jq
  ];

  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    userName = "lain540";
    userEmail = "lain540@users.noreply.github.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#leavenworth";
      update = "cd /etc/nixos && sudo ./scripts/rebuild.sh";
    };
    shellInit = ''
      set fish_greeting
    '';
  };

  # Hyprland configuration - minimal, no animations
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
        drop_shadow = false;
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

      # Autostart
      exec-once = [
        "eww daemon"
        "eww open bar"
        "dunst"
      ];
    };
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
        font = "Terminus 10";
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

  # Foot terminal - minimal
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Terminus:size=11";
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

  # nnn file manager
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
  };

  programs.nixvim = {
    enable = true;
    
    colorschemes.base16 = {
      enable = true;
      colorscheme = "default-dark";
    };

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      hlsearch = true;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      updatetime = 50;
    };

    globals.mapleader = " ";

    plugins = {
      lsp = {
        enable = true;
        servers = {
          lua-ls.enable = true;
          nixd.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
          clangd.enable = true;
          pyright.enable = true;
        };
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          lua nix rust c python bash
        ];
      };

      neo-tree.enable = true;
      telescope.enable = true;
      
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };

      lualine.enable = true;
    };
  };

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # eww configuration
  xdg.configFile."eww/eww.yuck".source = ./dotfiles/eww/eww.yuck;
  xdg.configFile."eww/eww.scss".source = ./dotfiles/eww/eww.scss;
}
