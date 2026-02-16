{ config, pkgs, ... }:

{
  # Applications
  home.packages = with pkgs; [
    # Music management
    beets
    
    # Music downloads
    slskd
  ];

  # Create music directories
  home.file = {
    "Music/.keep".text = "";
    "Downloads/slskd/.keep".text = "";
    "Downloads/slskd/incomplete/.keep".text = "";
    "Downloads/slskd/complete/.keep".text = "";
  };

  # Beets music library management configuration
  xdg.configFile."beets/config.yaml".text = ''
    # Library location
    directory: ~/Music
    library: ~/Music/library.db
    
    # Import settings
    import:
      move: yes                # Move files (not copy) into library
      write: yes               # Write tags to files
      copy: no                 # Don't copy, move instead
      delete: no               # Don't delete originals after import
      timid: no                # Don't ask for confirmation on every album
      quiet_fallback: skip     # Skip albums without good matches
      incremental: yes         # Skip already-imported albums
      
    # Auto-tagging
    match:
      strong_rec_thresh: 0.10  # Threshold for very strong matches
      medium_rec_thresh: 0.25  # Threshold for medium matches
      rec_gap_thresh: 0.25     # Gap between first and second match
      
    # Paths - organize music by artist/album
    paths:
      default: $albumartist/$album%aunique{}/$track $title
      singleton: $artist/Singles/$title
      comp: Compilations/$album%aunique{}/$track $title
      
    # Replace characters in filenames
    replace:
      '[\\\/]': _
      '^\.': _
      '[\x00-\x1f]': _
      '[<>:"\?\*\|]': _
      '\.$': _
      '\s+$': ''
      
    # Plugins
    plugins: fetchart embedart scrub replaygain lastgenre chroma
    
    # Plugin settings
    fetchart:
      auto: yes
      cautious: yes
      
    embedart:
      auto: yes
      
    replaygain:
      auto: no  # Manual, as it can be CPU intensive
      
    lastgenre:
      auto: yes
      source: track
  '';

  # slskd systemd service
  systemd.user.services.slskd = {
    Unit = {
      Description = "slskd - Soulseek client";
      After = [ "network.target" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.slskd}/bin/slskd --config ~/.config/slskd";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # slskd configuration
  xdg.configFile."slskd/slskd.yml".text = ''
    # Network
    listen:
      host: 127.0.0.1
      port: 5030
    
    # Web UI
    web:
      authentication:
        username: svea
        # Password will be set on first run
        # Visit http://localhost:5030 to set it up
    
    # Directories
    directories:
      downloads: ~/Downloads/slskd/complete
      incomplete: ~/Downloads/slskd/incomplete
      
    # Shared directories for uploading
    shares:
      directories:
        - ~/Music
    
    # Global settings
    global:
      upload:
        slots: 2
      download:
        slots: 5
    
    # Soulseek settings
    soulseek:
      description: "Music collector"
      listen_port: 50300
      enable_distributed_network: true
  '';
}
