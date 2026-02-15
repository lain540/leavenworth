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

  # Console keymap - Workman layout
  console.keyMap = "us";

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

  # Fish shell - enable system-wide to add to /etc/shells
  programs.fish.enable = true;

  # musnix - audio optimization for music production
  musnix.enable = true;
  musnix.rtirq.enable = true;

  # User
  users.users.svea = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager" "audio" "video" "input" 
      "dialout" "plugdev" "storage" "optical" "scanner" "lp"
    ];
    initialPassword = "changeme";
    shell = pkgs.fish;  # Set Fish as default shell
  };
  security.sudo.wheelNeedsPassword = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim git wget curl htop
  ];

  # VirtualBox (uncomment for VM testing, remove for real hardware)
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.x11 = true;

  system.stateVersion = "24.11";
}
