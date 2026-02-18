{ config, pkgs, inputs, ... }:

{
  # ── Hyprland ──────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable          = true;
    package         = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # ── Greeter ───────────────────────────────────────────────────────────────────
  # --output HDMI-A-1 ensures tuigreet renders on the ultrawide at boot,
  # not whichever connector the kernel happened to initialise first.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --output HDMI-A-1 --cmd start-hyprland";
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
  # Launch Reaper via `pw-jack reaper` to connect to the JACK bridge.
  # AKAI MPK Mini Mk3 is USB class-compliant — appears automatically in
  # Reaper under Preferences → Audio → MIDI devices.
  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;

    # 256/48000 ≈ 5.3 ms latency; lower quantum = less latency, more CPU
    extraConfig.pipewire."99-leavenworth-audio"."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 256;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 2048;
    };

    # Expose ALSA MIDI sequencer ports (MPK Mini Mk3) into PipeWire
    wireplumber = {
      enable = true;
      extraConfig."99-leavenworth-midi"."monitor.alsa.midi".enable = true;
    };
  };

  # ── Audio plugins — system-level ──────────────────────────────────────────────
  # Plugins must be in systemPackages so musnix's auto-set VST3_PATH / LV2_PATH
  # (which point at /run/current-system/sw/lib/*) actually covers them.
  # Plugins installed via home.packages land in ~/.nix-profile/lib/* which
  # musnix does NOT include in its path variables.
  environment.systemPackages = with pkgs; [
    # MTP / automount
    jmtpfs libmtp udiskie

    # pw-jack — launch Reaper with `pw-jack reaper`
    pipewire

    # Audio plugins — found automatically by Reaper via musnix paths
    lsp-plugins       # Linux Studio Plugins (LV2/VST3)
    surge-XT          # wavetable / subtractive synth (VST3/LV2)
    cardinal          # VCV Rack modular (VST3/LV2)
    dexed             # Yamaha DX7 FM (VST3)
    airwindows-lv2    # large collection of subtle effects (LV2)
    dragonfly-reverb  # hall/room/plate reverb (VST3/LV2)
    chow-tape-model   # analog tape emulation (VST3)
    # chow-phaser / chow-kick / chow-centaur removed — crash on load (JUCE ABI issue)
  ];

  # ── Storage & devices ─────────────────────────────────────────────────────────
  services.udisks2.enable = true;
  services.gvfs.enable    = true;  # MTP, SFTP, trash
}
