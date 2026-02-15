{ config, pkgs, inputs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    inputs.musnix.nixosModules.musnix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System
  networking.hostName = "leavenworth";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Fish shell
  programs.fish.enable = true;

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
    vim git wget curl htop
  ];

  system.stateVersion = "24.11";
}
