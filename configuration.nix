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
  # Limit boot menu entries - only show the last 3 generations
  boot.loader.systemd-boot.configurationLimit = 3;

  # AMD Ryzen 7 5700G - Radeon Vega iGPU
  # RADV (Vulkan) is enabled by default in nixpkgs - no need to add amdvlk manually.
  # amdvlk was removed from nixpkgs because RADV is now the preferred driver.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # AMD ROCm OpenCL - required for DaVinci Resolve GPU compute
      rocmPackages.clr
      rocmPackages.clr.icd
      # VDPAU / VAAPI video decode acceleration
      libvdpau-va-gl
      libva-vdpau-driver  # renamed from vaapiVdpau in nixpkgs-unstable
    ];
  };

  # amdgpu kernel driver - enables the iGPU properly
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # System
  networking.hostName = "leavenworth";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Console (TTY) keyboard layout - uses XKB configuration
  console = {
    useXkbConfig = true;
    earlySetup = true;
  };
  
  # Even if you don't use X11, NixOS uses these settings to derive the console map
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

  # ROCm GPU target for Ryzen 7 5700G (Radeon Vega / gfx90c)
  # Without this DaVinci Resolve can't detect the GPU for compute tasks
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";
  };

  # Networking
  networking.networkmanager.enable = true;

  # Fish shell - system-wide (adds to /etc/shells)
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
      "adbusers"
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
