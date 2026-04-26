
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
    extraConfig.pipewire."99-virtual-mic" = { # Virtual devices for AudioRelay
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "Virtual-Mic-Sink";
            "capture.props" = {
              "node.name" = "audiorelay-virtual-mic-sink";
              "media.class" = "Audio/Sink";
              "audio.position" = [ "FL" "FR" ];
            };
            "playback.props" = {
              "node.name" = "audiorelay-virtual-mic-source";
              "node.description" = "Virtual-Mic";
              "media.class" = "Audio/Source";
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
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

  programs = {
    firefox.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };
    htop.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
      };
  };
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      pkgs-master = import inputs.nixpkgs-master {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = with pkgs; [
    # Flakes
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
    pkgs-master.osu-lazer-bin
    inputs.heroic.legacyPackages.${pkgs.stdenv.hostPlatform.system}.heroic

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
    wineWow64Packages.stable
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
  ];

  services = {
    flatpak.enable = true;
    xserver.videoDrivers = ["nvidia"];
    wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
    };
    qbittorrent = {
      enable = true;
      openFirewall = true;
    };
    ratbagd.enable = true;
  };

  # OpenGL
  hardware.graphics = {
      enable = true;
      enable32Bit = true;
  };

  # NVIDIA

  hardware.nvidia = {

  modesetting.enable = true;
  powerManagement = {
    enable = false;
    finegrained = false;
    };
  open = true;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Bluetooth
  hardware.bluetooth = {
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
    allowedTCPPorts = [ 29150 59100 ];
    allowedUDPPorts = [ 29150 59100 59200 ];
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
