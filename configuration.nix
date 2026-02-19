{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/nixos/desktop.nix
    inputs.musnix.nixosModules.musnix
  ];

  # ── Boot ─────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable        = true;
  boot.loader.efi.canTouchEfiVariables   = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # Tell the kernel to initialise DP-1 first so early boot text
  # (initrd, greetd) renders on the ultrawide, not the secondary display.
  boot.kernelParams = [
    # Pin the ultrawide to its native resolution in the kernel framebuffer.
    # Only specifying DP-1 here — adding video=HDMI-A-1:d to disable the
    # secondary at TTY level also disables it at the DRM level on amdgpu,
    # preventing Hyprland from bringing it back up.
    "video=DP-1:3440x1440@60"
  ];

  # ── Hardware ──────────────────────────────────────────────────────────────────
  # AMD Ryzen 7 5700G — Radeon Vega iGPU (RADV Vulkan enabled by default via Mesa)
  boot.initrd.kernelModules     = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr      # ROCm OpenCL — needed for DaVinci Resolve GPU compute
      rocmPackages.clr.icd
      libvdpau-va-gl        # VDPAU/VAAPI video decode
      libva-vdpau-driver
    ];
  };

  # ROCm target override for Vega (gfx90c) — required by DaVinci Resolve
  environment.variables = {
    ROC_ENABLE_PRE_VEGA      = "1";
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";
  };

  # Gaomon M10K drawing tablet — run `otd-gui` after first boot to calibrate
  hardware.opentabletdriver.enable        = true;
  hardware.opentabletdriver.daemon.enable = true;
  hardware.uinput.enable                  = true;  # virtual input device, required by OTD

  # ── System ────────────────────────────────────────────────────────────────────
  networking.hostName      = "leavenworth";
  networking.networkmanager.enable = true;
  time.timeZone            = "Europe/Stockholm";
  i18n.defaultLocale       = "en_US.UTF-8";

  # Console keyboard follows XKB settings below
  console = { useXkbConfig = true; earlySetup = true; };

  # Default layout: US Workman; switch to Swedish with Super+Space in Hyprland
  services.xserver.xkb = { layout = "us"; variant = "workman"; };

  # ── Nix ───────────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store   = true;
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;

  # ── Shell & programs ──────────────────────────────────────────────────────────
  programs.zsh.enable = true;

  # nix-ld — run unpatched pre-compiled binaries on NixOS.
  # ReaPack downloads native .so extensions (ReaImGui, etc.) that are linked
  # against glibc at /lib/x86_64-linux-gnu/ which doesn't exist on NixOS.
  # nix-ld provides a stub ld.so at that path so those binaries load correctly.
  # libraries: common C/C++ runtimes that downloaded plugins typically need.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib  # libstdc++.so.6
      glibc             # libc, libm
      freetype          # libfreetype.so.6
      libpng            # libpng16.so.16
      zlib              # libz.so.1
      fontconfig        # libfontconfig.so.1
      libepoxy          # libepoxy.so.0
      gtk3              # libgtk-3.so.0, libgdk-3.so.0
      cairo             # libcairo.so.2
      glib              # libgobject-2.0.so.0, libglib-2.0.so.0
    ];
  };

  # ── musnix — real-time audio ──────────────────────────────────────────────────
  # Sets CPU scheduler, rtirq priorities, and plugin path env vars automatically.
  # Launch Reaper via `pw-jack reaper` to use the PipeWire JACK bridge.
  musnix.enable        = true;
  musnix.rtirq.enable  = true;

  # ── Stylix — system-wide base16 theming ───────────────────────────────────────
  # Change base16Scheme to swap the colour scheme everywhere at once.
  # Available schemes: ls ${pkgs.base16-schemes}/share/themes/
  stylix = {
    enable       = true;
    polarity     = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

    # Leave the TTY/console unstyled — plain text before Hyprland starts.
    targets.console.enable = false;

    # Cursor — set system-wide so GTK, Hyprland and XWayland all agree
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name    = "Adwaita";
      size    = 24;
    };

    # Fonts — Hack Nerd Font for everything; stylix propagates through fontconfig,
    # GTK, and any target that reads stylix.fonts (foot, fuzzel, nvf lualine…)
    fonts = {
      monospace = { name = "Hack Nerd Font Mono";   package = pkgs.nerd-fonts.hack; };
      sansSerif = { name = "Hack Nerd Font";         package = pkgs.nerd-fonts.hack; };
      serif     = { name = "Hack Nerd Font Propo";   package = pkgs.nerd-fonts.hack; };
      emoji     = { name = "Noto Color Emoji";        package = pkgs.noto-fonts-color-emoji; };
      sizes     = { terminal = 14; applications = 14; desktop = 14; popups = 14; };
    };
  };

  # ── User ──────────────────────────────────────────────────────────────────────
  users.users.svea = {
    isNormalUser = true;
    shell        = pkgs.zsh;
    initialPassword = "changeme";
    extraGroups  = [
      "wheel" "networkmanager"
      "audio" "video" "input"
      "dialout" "plugdev" "storage" "optical" "scanner" "lp"
      "adbusers"
    ];
  };
  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    curl htop

    # These must be in systemPackages so they land in /run/current-system/sw/lib.
    # nix-ld.libraries alone does NOT put them there — it only exposes them to
    # the nix-ld stub linker. ReaPack extensions (ReaImGui etc.) need them at
    # the standard LD_LIBRARY_PATH location to load at runtime.
    freetype     # libfreetype.so.6
    libpng        # libpng16.so.16
    zlib          # libz.so.1
    fontconfig    # libfontconfig.so.1
    libepoxy      # libepoxy.so.0
    gtk3          # libgtk-3.so.0, libgdk-3.so.0
    cairo         # libcairo.so.2
    glib          # libgobject-2.0.so.0, libglib-2.0.so.0
    stdenv.cc.cc.lib  # libstdc++.so.6
  ];

  system.stateVersion = "25.11";
}
