
{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "nakamura-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire = {
      "10-null-sink" = {  # Virtual devices for AudioRelay
        "context.objects" = [ {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "audiorelay-virtual-mic-sink";
            "node.description" = "Virtual Mic Sink";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        } ];
      };
      "20-virtual-mic" = {
        "context.modules" = [ {
          name = "libpipewire-module-loopback";
          args = {
            "capture.props" = {
              "node.target" = "audiorelay-virtual-mic-sink";
            };
            "playback.props" = {
              "node.name" = "audiorelay-virtual-mic";
              "node.description" = "Virtual Mic";
              "media.class" = "Audio/Source";
              "audio.position" = "FL,FR";
              "node.passive" = true;
            };
          };
        } ];
      };
    };
  };


  users.users.natselketi = {
    isNormalUser = true;
    description = "Natselketi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  system.userActivationScripts = {
    linkProton = {
      text= ''
        mkdir -p $HOME/.config/heroic/tools/proton/
        ln -sfn ${pkgs.proton-ge-bin.steamcompattool} $HOME/.config/heroic/tools/proton/GE-Proton-Latest
        ln -sfn ${pkgs.nur.repos.forkprince.proton-ge-rtsp-bin.steamcompattool} $HOME/.config/heroic/tools/proton/Proton-GE-RTSP
      '';
    };
  };

  programs = {
    firefox.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin forkprince.proton-ge-rtsp-bin ];
      package = pkgs.millennium-steam;
     # package = (pkgs.millennium-steam.override {
     #   extraEnv = {
     #     LD_AUDIT = "${inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam}/library-inject.so:${inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam}/SLSsteam.so";
     #     };
     #   });
      };
    htop.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
      };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        ];
      };
  };
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      osu-lazer = import inputs.osu-lazer {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
      forkprince = import inputs.forkprince {
        pkgs = prev;
      };
    })
    inputs.millennium.overlays.default
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-gaming.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://forkprince.cachix.org"
    ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "forkprince.cachix.org-1:9cN+fX492ZKlfd228xpYAC3T9gNKwS1sZvCqH8iAy1M="
    ];
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache"; # XDG Base Directory Specification
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
  };

  environment.systemPackages = with pkgs; [
    # Flakes
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
    osu-lazer.osu-lazer-bin
    inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.wrapped
    nur.repos.zerozawa.mikusays
    inputs.nix-audiorelay.packages.${pkgs.stdenv.hostPlatform.system}.audiorelay
    nur.repos.lonerOrz.helium

    # Nix packages
    vim
    git
    wget
    librewolf
    equibop
    prismlauncher
    fastfetch
    obs-studio
    p7zip
    vlc
    wineWow64Packages.stableFull
    winetricks
    protonplus
    file
    killall
    qjackctl
    kew
    unar
    piper
    ntfs3g
    proton-pass
    proton-authenticator
    proton-vpn
    riseup-vpn
    scrcpy
    kdePackages.filelight
    android-tools
    tealdeer
    xclip
    bat
    gh
    distrobox
    gamemode
    ghostty
    tmux
    python314
    pipx
    wayvr
    zulu21
    qbittorrent-enhanced
    yt-dlp
    ffmpeg
    (discord.override { equicord = forkprince.equicord; withEquicord = true; })
    sgdboop
    heroic
  ];

  services = {
    flatpak.enable = true;
    xserver.videoDrivers = ["nvidia"];
    wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
      steam = {
        enable = true;
        importOXRRuntimes = true;
      };
    };
    qbittorrent = {
      enable = true;
      openFirewall = true;
    };
    ratbagd.enable = true;
    zerotierone = {
      enable = true;
      package = pkgs.zerotierone;
      port = 9993;
    };
  };

  hardware = { # OpenGL
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = { # NVIDIA
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
        };
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    bluetooth = { # Bluetooth
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          };
        Policy.AutoEnable = true;
      };
    };
  };

  # Waydroid
  virtualisation.waydroid.enable = true;

  # Fonts!
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9993 25565 29150 59100 ];
    allowedUDPPorts = [ 9993 29150 59100 59200 ];
  };

  # Mounts
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems = {
    #HD1
    "/media/hd1" = {
      device = "/dev/disk/by-uuid/0C307A68307A58A2";
      fsType = "lowntfs-3g";
      options = ["uid=1000" "gid=1000" "rw" "user" "exec" "nofail" "umask=000"];
    };
    #HD Linux
    "/media/hdlinux" = {
      device = "/dev/disk/by-uuid/78864642-9caf-4a74-be61-98b4fdc4c2dc";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };
    # Arch Linux
    "/media/archlinux" = {
      device = "/dev/disk/by-uuid/b2895cc7-0273-4a6f-a66b-40e21ba88443";
      fsType = "ext4";
      options = ["defaults" "nofail"];
    };
  };

  system.stateVersion = "25.11";
}
