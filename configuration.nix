{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system/desktop.nix
    inputs.musnix.nixosModules.musnix
  ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # ── GPU — AMD Ryzen 7 5700G (Radeon Vega iGPU) ──────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr        # AMD ROCm OpenCL for DaVinci Resolve GPU compute
      rocmPackages.clr.icd
      libvdpau-va-gl          # VDPAU/VAAPI video decode acceleration
      libva-vdpau-driver      # renamed from vaapiVdpau in nixpkgs-unstable
    ];
  };
  boot.initrd.kernelModules    = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # ── Drawing tablet — OpenTabletDriver ────────────────────────────────────────
  # Supports Gaomon M10K and most other USB tablets out of the box.
  # After first boot run `otd-gui` to set pen area mapping and calibrate.
  # The daemon runs as a systemd user service — starts automatically on login.
  hardware.opentabletdriver = {
    enable        = true;
    daemon.enable = true;
  };
  # uinput — virtual input kernel module required by OpenTabletDriver
  hardware.uinput.enable = true;
  # NOTE: boot.initrd.kernelModules above already contains "amdgpu".
  # We add "uinput" via hardware.uinput.enable; it handles the kernel module.

  # ── System ───────────────────────────────────────────────────────────────────
  networking.hostName = "leavenworth";
  time.timeZone       = "Europe/Stockholm";
  i18n.defaultLocale  = "en_US.UTF-8";

  console = {
    useXkbConfig = true;
    earlySetup   = true;
  };
  services.xserver.xkb = {
    layout  = "us";
    variant = "workman";
  };

  # ── Nix ──────────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store   = true;
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    ROC_ENABLE_PRE_VEGA      = "1";
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";
  };

  # ── Networking ───────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Shell ─────────────────────────────────────────────────────────────────────
  programs.zsh.enable = true;

  # ── musnix ───────────────────────────────────────────────────────────────────
  musnix.enable       = true;
  musnix.rtirq.enable = true;

  # ── Stylix ───────────────────────────────────────────────────────────────────
  stylix = {
    enable       = true;
    polarity     = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/base16-default-dark.yaml";

    # No stylix.image set — we use an explicit base16Scheme so stylix doesn't
    # need an image for colour extraction, and swaybg is disabled in
    # home/desktop.nix so nothing tries to display a wallpaper.
    # If the build fails with "stylix.image is not defined", your stylix version
    # still requires it — set it to any image path as a workaround.

    # ── Cursor ────────────────────────────────────────────────────────────────
    # Setting this here ensures the cursor is applied system-wide (greetd, GTK,
    # Hyprland, XWayland). Without it Hyprland falls back to its own logo cursor.
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name    = "Adwaita";
      size    = 24;
    };

    # ── Fonts — Hack Nerd Font everywhere ────────────────────────────────────
    fonts = {
      monospace = {
        name    = "Hack Nerd Font Mono";
        package = pkgs.nerd-fonts.hack;
      };
      sansSerif = {
        name    = "Hack Nerd Font";
        package = pkgs.nerd-fonts.hack;
      };
      serif = {
        name    = "Hack Nerd Font Propo";
        package = pkgs.nerd-fonts.hack;
      };
      emoji = {
        name    = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      sizes = {
        terminal     = 11;
        applications = 11;
        desktop      = 11;
        popups       = 11;
      };
    };
  };

  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.svea = {
    isNormalUser = true;
    extraGroups  = [
      "wheel" "networkmanager" "audio" "video" "input"
      "dialout" "plugdev" "storage" "optical" "scanner" "lp"
      "adbusers"
    ];
    initialPassword = "changeme";
    shell           = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = true;

  # ── System packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    curl
    htop
  ];

  system.stateVersion = "25.11";
}
