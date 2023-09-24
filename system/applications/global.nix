# PACKAGES INSTALLED ON ALL USERS
{ pkgs, config, inputs, lib, ... }:

let
  trim-generations = pkgs.writeShellScriptBin "trim-generations"
    (builtins.readFile ../scripts/trim-generations.sh);

  nix-gc = pkgs.writeShellScriptBin "nix-gc" ''
    gens=${config.system.gc.generations} ;
    days=${config.system.gc.days} ;
    trim-generations ''${1:-$gens} ''${2:-$days} user ;
    trim-generations ''${1:-$gens} ''${2:-$days} home-manager ;
    sudo -H -u ${config.system.user.work.username} env Gens="''${1:-$gens}" Days="''${2:-$days}" bash -c 'trim-generations $Gens $Days user' ;
    sudo -H -u ${config.system.user.work.username} env Gens="''${1:-$gens}" Days="''${2:-$days}" bash -c 'trim-generations $Gens $Days home-manager' ;
    sudo trim-generations ''${1:-$gens} ''${2:-$days} system ;
    nix-store --gc
  '';

  vpn-exclude = pkgs.writeShellScriptBin "vpn-exclude"
    (builtins.readFile ../scripts/create-ns.sh);

  lout = pkgs.writeShellScriptBin "lout" ''
    pkill -KILL -u $USER
  '';

  codingDeps = with pkgs; [
    cargo # Rust package manager
    dotnet-sdk_7 # SDK for .net
    gcc # C++ compiler
    gdtoolkit # Tools for gdscript
    nixfmt # A nix formatter
    nodejs # Node package manager
    python3 # Python
    vscodium # All purpose IDE
  ];

  nvchadDeps = with pkgs; [
    beautysh # Bash formatter
    black # Python formatter
    lazygit # Git CLI UI
    libclang # C language server and formatter
    lua-language-server # Lua language server
    marksman # Markdown language server
    neovim # Terminal text editor
    nil # Nix language server
    nodePackages.bash-language-server # Bash Language server
    nodePackages.dockerfile-language-server-nodejs # Dockerfiles language server
    nodePackages.prettier # Javascript/Typescript formatter
    nodePackages.typescript-language-server # Typescript language server
    nodePackages.vscode-langservers-extracted # HTML, CSS, Eslint, Json language servers
    python3Packages.jedi-language-server # Python language server
    ripgrep # Silver searcher grep
    rust-analyzer # Rust language server
    rustfmt # Rust formatter
    stylua # Lua formatter
  ];
in {
  boot.kernelPackages = pkgs.linuxPackages_zen; # Use ZEN linux kernel

  environment.systemPackages = with pkgs;
    [
      (callPackage ./self-built/apx.nix { }) # Package manager using distrobox
      (callPackage ./self-built/webcord { }) # An open source discord client
      (firefox.override {
        extraNativeMessagingHosts =
          [ inputs.pipewire-screenaudio.packages.${pkgs.system}.default ];
      }) # Browser
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
      }) # Pipewire audio plugin for OBS Studio
      android-tools # Tools for debugging android devices
      appimage-run # Appimage runner
      aria # Terminal downloader with multiple connections support
      bat # Better cat command
      bless # HEX Editor
      btop # System monitor
      clamav # Antivirus
      curtail # Image compressor
      easyeffects # Pipewire effects manager
      efibootmgr # Edit EFI entries
      endeavour # Tasks
      fd # Find alternative
      feh # Minimal image viewer
      fragments # Bittorrent client following Gnome UI standards
      gimp # Image editor
      git # Distributed version control system
      gnome.gnome-boxes # VM manager
      gping # ping with a graph
      gthumb # Image viewer
      helvum # Pipewire patchbay
      iotas # Notes
      jc # JSON parser
      jq # JSON parser
      killall # Tool to kill all programs matching process name
      kitty # Terminal
      libnotify # Send desktop notifications
      lout # Logout from any shell
      lsd # Better ls command
      mousai # Song recognizer
      mpv # Video player
      ncdu # Terminal disk analyzer
      newsflash # RSS reader
      nix-gc # Garbage collect old nix generations
      ntfs3g # Support NTFS drives
      obs-studio # Recording/Livestream
      onlyoffice-bin # Microsoft Office alternative for Linux
      p7zip # 7zip
      pitivi # Video editor
      ranger # Terminal file manager
      rnnoise-plugin # A real-time noise suppression plugin
      signal-desktop # Encrypted messaging platform
      sunshine # Remote desktop
      tailscale # VPN with P2P support
      tmux # Terminal multiplexer
      trayscale # Tailscale GUI
      tree # Display folder content at a tree format
      trim-generations # Smarter old nix generations cleaner
      unrar # Support opening rar files
      unzip # An extraction utility
      vpn-exclude # Run shell with another gateway and IP
      warp # File sync
      wget # Terminal downloader
      wine # Compatibility layer capable of running Windows applications
      winetricks # Wine prefix settings manager
      woeusb # Windows ISO Burner
      xorg.xhost # Use x.org server with distrobox
      youtube-dl # Video downloader
      zenstates # Ryzen CPU controller
      scrcpy
    ] ++ codingDeps ++ nvchadDeps;

  users.defaultUserShell = pkgs.zsh; # Use ZSH shell for all users

  programs = {
    zsh = {
      enable = true;
      # Enable oh my zsh and it's plugins
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "npm" "sudo" "systemd" ];
      };
      autosuggestions.enable = true;

      syntaxHighlighting.enable = true;

      # Aliases
      shellAliases = {
        apx = "apx --aur"; # Use arch as the base apx container
        aria2c = "aria2c -j 16 -s 16"; # Download with aria using best settings
        btrfs-compress =
          "sudo btrfs filesystem defrag -czstd -r -v"; # Compress given path with zstd
        cat = "bat"; # Better cat command
        chmod = "sudo chmod"; # It's a command that I always execute with sudo
        clear-keys =
          "sudo rm -rf ~/ local/share/keyrings/* ~/ local/share/kwalletd/*"; # Clear system keys
        cp = "rsync -rP"; # Copy command with details
        desktop-files-list =
          "ls -l /run/current-system/sw/share/applications"; # Show desktop files location
        list-packages =
          "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq"; # List installed nix packages
        ls = "lsd"; # Better ls command
        mva = "rsync -rP --remove-source-files"; # Move command with details
        n = "tmux a -t nvchad || tmux new -s nvchad nvim"; # Nvchad
        ping = "gping"; # ping with a graph
        reboot-windows =
          "sudo efibootmgr --bootnext ${config.boot.windows-entry} && reboot"; # Reboot to windows
        rebuild = "(cd ${
            builtins.readFile ../../.configuration-location
          } 2> /dev/null || (echo 'Configuration path is invalid. Run build.sh manually to update the path!' && false) && bash build.sh)"; # Rebuild the system configuration
        restart-pipewire =
          "systemctl --user restart pipewire"; # Restart pipewire
        server = "ssh server@192.168.1.2"; # Connect to local server
        ssh = "TERM=xterm-256color ssh"; # SSH with colors
        steam-link =
          "killall steam 2> /dev/null ; while ps axg | grep -vw grep | grep -w steam > /dev/null; do sleep 1; done && (nohup steam -pipewire > /dev/null &) 2> /dev/null"; # Kill existing steam process and relaunch steam with the pipewire flag
        update = "(cd ${
            builtins.readFile ../../.configuration-location
          } 2> /dev/null || (echo 'Configuration path is invalid. Run build.sh manually to update the path!' && false) && nix flake update && bash build.sh) ; (apx --aur upgrade) ; (bash ~/.config/zsh/proton-ge-updater.sh) ; (bash ~/.config/zsh/steam-library-patcher.sh) ; (bash ~/.config/zsh/update-codium-extensions.sh)"; # Update everything
        v = "nvim"; # Neovim
        vpn = "ssh -f server@192.168.1.2 'mullvad status'"; # Show VPN status
        vpn-btop = "ssh -t server@192.168.1.2 'bpytop'"; # Show VPN bpytop
        vpn-off =
          "ssh -f server@192.168.1.2 'mullvad disconnect && sleep 1 && mullvad status'"; # Disconnect from VPN
        vpn-on =
          "ssh -f server@192.168.1.2 'mullvad connect && sleep 1 && mullvad status'"; # Connect to VPN
      };

      interactiveShellInit = ''
        source ~/.config/zsh/zsh-theme.zsh
        unsetopt PROMPT_SP''; # Commands to run on zsh shell initialization
    };

    # Enable gamemode and set custom settings
    gamemode = {
      enable = true;
      settings = {
        general.renice = 20;
        gpu = {
          apply_gpu_optimisations = 1;
          nv_powermizer_mode = 1;
          amd_performance_level = "high";
        };
      };
    };
  };

  security.wrappers = {
    sunshine = {
      owner = "root";
      group = "root";
      source = "${pkgs.sunshine}/bin/sunshine";
      capabilities = "cap_sys_admin+p";
    };
  };

  services = {
    clamav.updater.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    udev.packages = [
      (pkgs.writeTextFile {
        name = "sunshine_udev";
        text = ''
          KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/85-sunshine.rules";
      }) # Needed for sunshine input to work
    ];
  };

  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        # https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/applications/video/mpv/scripts
        scripts = [
          pkgs.mpvScripts.mpris # Allow control with standard media keys
          pkgs.mpvScripts.thumbfast # Thumbnailer
          pkgs.mpvScripts.uosc # Feature-rich minimalist proximity-based UI
        ] ++ lib.optional config.desktop.gnome.enable
          pkgs.mpvScripts.inhibit-gnome; # Prevent gnome screen blanking while playing media
      };
    })
  ];

  # Symlink files and folders to /etc
  environment.etc."rnnoise-plugin/librnnoise_ladspa.so".source =
    "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
  environment.etc."proton-ge-nix".source =
    "${(pkgs.callPackage self-built/proton-ge.nix { })}/";
  environment.etc."apx/config.json".source =
    "${(pkgs.callPackage self-built/apx.nix { })}/etc/apx/config.json";
}