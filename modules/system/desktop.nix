{ config, pkgs, inputs, ... }:

{
  # ── Hyprland ──────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable          = true;
    package         = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # ── Greeter ───────────────────────────────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      user    = "greeter";
    };
  };

  # ── XDG portals ───────────────────────────────────────────────────────────────
  xdg.portal = {
    enable        = true;
    extraPortals  = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # ── Audio — PipeWire + JACK bridge ────────────────────────────────────────────
  # Launch Reaper via `pw-jack reaper` to use the JACK bridge.
  # AKAI MPK Mini Mk3 is USB class-compliant — no driver needed; appears
  # automatically in Reaper under Preferences → Audio → MIDI devices.
  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;  # JACK bridge for Reaper

    # Low-latency tuning: 256/48000 ≈ 5.3 ms; lower quantum = less latency, more CPU
    extraConfig.pipewire."99-leavenworth-audio"."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 256;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 2048;
    };

    # Bridge ALSA MIDI sequencer ports (MPK Mini Mk3) into PipeWire
    wireplumber = {
      enable = true;
      extraConfig."99-leavenworth-midi"."monitor.alsa.midi".enable = true;
    };
  };

  # ── Storage & devices ─────────────────────────────────────────────────────────
  services.udisks2.enable = true;
  services.gvfs.enable    = true;  # MTP, SFTP, trash

  environment.systemPackages = with pkgs; [
    # MTP (Android phones)
    jmtpfs libmtp
    # Auto-mount daemon (also launched in Hyprland exec-once)
    udiskie
    # pw-jack: launch Reaper in JACK mode with `pw-jack reaper`
    pipewire
  ];
}
