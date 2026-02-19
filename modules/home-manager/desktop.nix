{ config, pkgs, inputs, ... }:

{
  # ── Hyprland ──────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable          = true;
    package         = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # ── Greeter ───────────────────────────────────────────────────────────────────
  # boot.kernelParams in configuration.nix hints the kernel to initialise
  # DP-1 first. That's the best we can do for monitor ordering at the
  # greetd/TTY level — tuigreet has no output-selection flag or env var.
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
  # AKAI MPK Mini Mk3 is USB class-compliant — appears automatically in
  # Reaper under Preferences → Audio → MIDI devices.
  security.rtkit.enable    = true;
  security.polkit.enable   = true;  # required for udiskie and device permissions

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;

    # 256/48000 ≈ 5.3 ms; lower quantum = less latency, more CPU
    extraConfig.pipewire."99-leavenworth-audio"."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 256;
      "default.clock.min-quantum" = 64;
      "default.clock.max-quantum" = 2048;
    };

    wireplumber = {
      enable = true;
      extraConfig."99-leavenworth-midi"."monitor.alsa.midi".enable = true;
    };
  };

  # udev rule: when an MTP device appears, run `gio mount` as svea inside
  # her running session so gvfs actually mounts it to /run/user/1000/gvfs/.
  # The DBUS_SESSION_BUS_ADDRESS lookup finds her active session bus so
  # gio can talk to the already-running gvfsd we start in exec-once.
  # GrapheneOS: unlock phone first, then select File Transfer in the
  # USB notification — the mount triggers automatically after ~2 seconds.
  services.udev.extraRules = '''
    SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", ACTION=="add", \
      RUN+="/bin/sh -c 'sleep 2; \
        export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; \
        /run/current-system/sw/bin/gio mount mtp:// 2>/dev/null || true'"
  ''';

  # ── Storage & devices ─────────────────────────────────────────────────────────
  services.udisks2.enable = true;
  services.gvfs.enable    = true;  # trash and SFTP support

  # ── System packages ───────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # MTP — manual mount: jmtpfs ~/Phone  unmount: fusermount -u ~/Phone
    jmtpfs libmtp udiskie

    # Polkit agent — needed so gvfs can prompt for device permissions
    # (without this, plugging in an Android phone silently fails)
    polkit_gnome

    # pw-jack — launch Reaper in JACK mode: pw-jack reaper
    pipewire

    # ── Processors / utility plugins ────────────────────────────────────────────
    lsp-plugins       # Linux Studio Plugins — EQs, compressors, dynamics (LV2/VST3)
    airwindows-lv2    # subtle console/tape effects (LV2)
    dragonfly-reverb  # hall / room / plate reverb (VST3/LV2)
    x42-plugins       # meters, MIDI tools, tuner, filters (LV2)
    zam-plugins       # dynamics, EQ, limiting (LV2/VST)

    infamousPlugins   # supersaw, powercut and other creative effects (LV2)
    distrho-ports     # ports of classic synths incl. Vitalium, OBXd, MaBitcrush (LV2/VST)

    # ── Tape / saturation / modelling ───────────────────────────────────────────
    wolf-shaper       # waveshaper / distortion with custom curve (LV2)
    chow-tape-model   # analog tape machine (VST3)
    chow-phaser       # phaser (VST3)
    chow-kick         # kick drum synth (VST3)
    chow-centaur      # Klon Centaur emulation (VST3)

    # ── Synths ──────────────────────────────────────────────────────────────────
    surge-xt          # wavetable / subtractive (VST3/LV2)
    cardinal          # VCV Rack modular (VST3/LV2)
    dexed             # Yamaha DX7 FM (VST3)

    odin2             # semi-modular synth (VST3/LV2)

    zynaddsubfx       # additive / subtractive / pad synth (LV2/VST)
    geonkick          # percussion / kick drum synth (LV2/VST3)
    sfizz             # SFZ sampler / player (LV2/VST3)

    bespokesynth      # modular live-coding synth environment (standalone)

    # ── Guitar ──────────────────────────────────────────────────────────────────
    guitarix          # guitar amp + effects rack (LV2/standalone)
  ];
}
