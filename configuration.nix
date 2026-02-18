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
  # RADV Vulkan is enabled by default via Mesa — no need to add amdvlk.
  hardware.graphics = {
    enable     = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr        # AMD ROCm OpenCL for DaVinci Resolve GPU compute
      rocmPackages.clr.icd
      libvdpau-va-gl          # VDPAU/VAAPI video decode acceleration
      libva-vdpau-driver      # renamed from vaapiVdpau in nixpkgs-unstable
    ];
  };
  boot.initrd.kernelModules   = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # ── System ───────────────────────────────────────────────────────────────────
  networking.hostName = "leavenworth";
  time.timeZone       = "Europe/Stockholm";
  i18n.defaultLocale  = "en_US.UTF-8";

  # Console keyboard layout derived from XKB settings below
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

  # ROCm target for Ryzen 7 5700G (gfx90c / Vega) — needed by DaVinci Resolve
  environment.variables = {
    ROC_ENABLE_PRE_VEGA      = "1";
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";
  };

  # ── Networking ───────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Shell — Zsh ──────────────────────────────────────────────────────────────
  # Enabling zsh system-wide adds it to /etc/shells, which is required for
  # it to be a valid login shell. Do NOT set programs.fish.enable here —
  # fish is no longer installed.
  programs.zsh.enable = true;

  # ── musnix — real-time audio optimisation ────────────────────────────────────
  musnix.enable         = true;
  musnix.kernel.realtime = false;
  musnix.rtirq.enable   = true;

  # ── Stylix — system-wide base16 theming ──────────────────────────────────────
  # Stylix applies a coherent colour scheme across the system: terminal,
  # editor, GTK apps, fonts etc. Change base16Scheme to swap the palette.
  #
  # Wallpaper: stylix needs an image for colour extraction. We provide a
  # solid #212121 placeholder so the build succeeds. Replace 'stylix.image'
  # with a path to your actual wallpaper:
  #   stylix.image = /path/to/wallpaper.png;
  # or via fetchurl:
  #   stylix.image = pkgs.fetchurl { url = "..."; hash = "sha256-..."; };
  stylix = {
    enable       = true;
    polarity     = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/charcoal-dark.yaml";

    # Solid dark placeholder wallpaper — replace with your own image
    image = pkgs.runCommand "wallpaper-placeholder.png" {
      buildInputs = [ pkgs.imagemagick ];
    } ''
      magick -size 1920x1080 xc:#212121 $out
    '';

    # ── Fonts — Hack Nerd Font everywhere ────────────────────────────────────
    # All four stylix font categories point to nerd-fonts.hack so that Hack
    # is the default for terminals, GTK apps, the desktop, and popups.
    # Stylix propagates these through fontconfig, GTK settings, and any
    # target that reads stylix.fonts (foot, fuzzel, nvf lualine, etc.)
    fonts = {
      monospace = {
        name    = "Hack Nerd Font Mono";  # terminals, editors, code
        package = pkgs.nerd-fonts.hack;
      };
      sansSerif = {
        name    = "Hack Nerd Font";       # GTK UI labels, buttons
        package = pkgs.nerd-fonts.hack;
      };
      serif = {
        name    = "Hack Nerd Font Propo"; # proportional variant for body text
        package = pkgs.nerd-fonts.hack;
      };
      emoji = {
        name    = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji;
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
    shell           = pkgs.zsh;   # switched from fish to zsh
  };
  security.sudo.wheelNeedsPassword = true;

  # ── System packages ──────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    curl
    htop
  ];

  system.stateVersion = "25.11";
}
