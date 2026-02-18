{ config, pkgs, inputs, ... }:

{
  # ── Hyprland ──────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable          = true;
    package         = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # ── Greeter ───────────────────────────────────────────────────────────────────
  # tuigreet does not have an --output flag in the nixpkgs build.
  # GREETD_OUTPUT is the correct way to pin the session to a connector.
  # boot.kernelParams in configuration.nix ensures the kernel itself initialises
  # HDMI-A-1 first so that DRM/KMS and greetd both agree on the primary output.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      user    = "greeter";
    };
  };
  environment.sessionVariables.GREETD_OUTPUT = "HDMI-A-1";

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
  # Must be in systemPackages so musnix's VST3_PATH/LV2_PATH covers them.
  # Plugins in home.packages land in ~/.nix-profile/lib/* which musnix ignores.
  environment.systemPackages = with pkgs; [
    # MTP / automount
    jmtpfs libmtp udiskie

    # pw-jack — launch Reaper with `pw-jack reaper`
    pipewire

    # Audio plugins
    lsp-plugins       # Linux Studio Plugins (LV2/VST3)
    surge-XT          # wavetable / subtractive synth (VST3/LV2)
    cardinal          # VCV Rack modular (VST3/LV2)
    dexed             # Yamaha DX7 FM (VST3)
    airwindows-lv2    # large collection of subtle effects (LV2)
    dragonfly-reverb  # hall/room/plate reverb (VST3/LV2)
    chow-tape-model   # analog tape emulation (VST3)
    chow-phaser       # phaser (VST3)
    chow-kick         # kick drum synth (VST3)
    chow-centaur      # Klon Centaur emulation (VST3)
  ];

  # ── Storage & devices ─────────────────────────────────────────────────────────
  services.udisks2.enable = true;
  services.gvfs.enable    = true;  # MTP, SFTP, trash — Android phones via gvfs
}
