{ config, pkgs, inputs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./modules/system/desktop.nix
    inputs.musnix.nixosModules.musnix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System
  networking.hostName = "leavenworth";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Console (TTY) keyboard layout - uses XKB configuration
  console = {
    useXkbConfig = true;
    earlySetup = true;  # Ensures the layout loads as early as possible (boot time)
  };
  
  # Even if you don't use X11, NixOS uses these variables to derive the console map
  services.xserver.xkb = {
    layout = "us";
    variant = "workman";
  };

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.networkmanager.enable = true;

  # Fish shell - system-wide (adds to /etc/shells)
  programs.fish.enable = true;

  # slskd - Soulseek client
  services.slskd = {
    enable = true;
    user = "svea";
    group = "users";
    domain = "localhost";
    
    settings = {
      # Network
      listen = {
        host = "127.0.0.1";
        port = 5030;
      };
      
      # Web UI authentication
      web = {
        authentication = {
          username = "svea";
          # Password will be set on first run via web UI
        };
      };
      
      # Directories
      directories = {
        downloads = "/home/svea/Downloads/slskd/complete";
        incomplete = "/home/svea/Downloads/slskd/incomplete";
      };
      
      # Shared directories for uploading
      shares = {
        directories = [
          "/home/svea/Music"
        ];
      };
      
      # Global settings
      global = {
        upload = {
          slots = 2;
        };
        download = {
          slots = 5;
        };
      };
      
      # Soulseek settings
      soulseek = {
        description = "Music collector";
        listen_port = 50300;
        enable_distributed_network = true;
      };
    };
  };

  # musnix - audio optimization
  musnix.enable = true;
  musnix.kernel.realtime = false;
  musnix.rtirq.enable = true;

  # User
  users.users.svea = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager" "audio" "video" "input" 
      "dialout" "plugdev" "storage" "optical" "scanner" "lp"
    ];
    initialPassword = "changeme";
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = true;

  # System packages
  environment.systemPackages = with pkgs; [
    curl
    htop
  ];

  system.stateVersion = "25.11";
}
