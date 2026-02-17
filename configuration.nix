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
  # Enables OpenGL, Vulkan and ROCm (needed for DaVinci Resolve GPU acceleration)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # AMD ROCm OpenCL - required for DaVinci Resolve GPU compute
      rocmPackages.clr
      rocmPackages.clr.icd
      # Vulkan
      amdvlk
      # VDPAU / VAAPI video decode acceleration
      libvdpau-va-gl
      vaapiVdpau
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

  # ROCm GPU target for Ryzen 7 5700G (Radeon Vega / gfx90c)
  # Without this DaVinci Resolve can't detect the GPU for compute tasks
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";  # Cezanne/Lucienne iGPU target
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
      "adbusers"  # Android MTP / ADB access
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
