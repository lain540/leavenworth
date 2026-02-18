{ config, pkgs, inputs, ... }:

{
  # Hyprland - system-level enablement
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # tuigreet - minimal login manager
  # Note: package was renamed from pkgs.greetd.tuigreet to pkgs.tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # Fonts are managed by stylix.fonts in configuration.nix — no need to list them here.

  # Portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # ── Audio — PipeWire with JACK bridge for Reaper ───────────────────────────
  # PipeWire replaces both PulseAudio and JACK. Reaper connects to it via the
  # JACK compatibility layer (services.pipewire.jack.enable = true).
  #
  # IMPORTANT — launch Reaper via pw-jack so it talks to PipeWire's JACK bridge:
  #   pw-jack reaper
  # Add this as a Hyprland keybind or a desktop entry wrapper if you want.
  # Without pw-jack, Reaper falls back to PulseAudio (no MIDI via JACK).
  #
  # AKAI MPK Mini Mk3 — USB class-compliant MIDI, no driver needed.
  # It appears as an ALSA sequencer device. PipeWire bridges it automatically.
  # In Reaper: Preferences → Audio → MIDI devices — enable the MPK Mini there.
  # If it doesn't appear, run: aconnect -l   to confirm the kernel sees it.
  security.rtkit.enable = true;

  services.pipewire = {
    enable      = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable  = true;  # PipeWire JACK bridge — required for Reaper JACK mode

    # PipeWire tuning for low-latency audio production
    # These override the default quantum (buffer size) and sample rate.
    # 256/48000 ≈ 5.3ms — good starting point; lower = less latency but more CPU.
    # Adjust quantum to 128 or 512 depending on your project complexity.
    extraConfig.pipewire."99-leavenworth-audio" = {
      "context.properties" = {
        "default.clock.rate"          = 48000;
        "default.clock.quantum"       = 256;
        "default.clock.min-quantum"   = 64;
        "default.clock.max-quantum"   = 2048;
      };
    };

    # WirePlumber (session manager) — MIDI sequencer bridge
    # Exposes ALSA MIDI sequencer ports (including the AKAI MPK Mini Mk3)
    # to PipeWire so Reaper sees them alongside audio devices.
    wireplumber = {
      enable = true;
      extraConfig."99-leavenworth-midi" = {
        "monitor.alsa.midi" = {
          enable = true;
        };
      };
    };
  };

  # Automounting
  services.udisks2.enable = true;

  # gvfs - MTP (phones), SFTP, trash support
  services.gvfs.enable = true;

  # android-udev-rules was removed from nixpkgs — systemd's built-in uaccess
  # rules now handle Android USB device access automatically. No replacement needed.

  # System packages for device mounting
  environment.systemPackages = with pkgs; [
    # MTP support for Android phones
    jmtpfs
    libmtp
    # udiskie tray icon and auto-mount daemon (also launched in Hyprland exec-once)
    udiskie
    # pw-jack wrapper — use this to launch Reaper in JACK mode:
    #   pw-jack reaper
    # pipewire ships pw-jack but it's in the pipewire package which is already present
    pipewire  # ensures pw-jack binary is in PATH
  ];
}
