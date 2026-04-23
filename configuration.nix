# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nakamura-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.natselketi = {
    isNormalUser = true;
    description = "Natselketi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
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
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    librewolf
    equibop
    heroic
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
  ];


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
