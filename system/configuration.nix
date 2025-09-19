# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nixpkgs settings
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.strings.getName pkg) [
    # List of allowed unfree packages
    "corefonts"
    "discord"
    #"ida-free"
    "nvidia-settings"
    "nvidia-x11"
    "obsidian"
    #"Oracle_VirtualBox_Extension_Pack"
    "postman"
    "spotify"
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
    "zerotierone"
    "zoom"
    "zoom-us"
  ];

  # Steam settings (from https://nixos.wiki/wiki/Steam)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks = {
      enable = true;
    };
  };

  # locate settings
  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  # Flatpak and add FlatHub repo (from https://nixos.wiki/wiki/Flatpak)
  services.flatpak.enable = true;
  systemd.services.configure-flathub-repo = {
    wantedBy = ["multi-user.target"];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  boot.initrd.luks.devices."luks-c9c4f91d-d176-43ad-b136-02b228cd15d1".device = "/dev/disk/by-uuid/c9c4f91d-d176-43ad-b136-02b228cd15d1";
  networking.hostName = "abusmachine"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Graphics settings
  #hardware.graphics.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };
  services.xserver.videoDrivers = [ "intel" ];
  #services.xserver.videoDrivers = [ "intel" "nvidia" ];
  #hardware.nvidia.open = true;
  #hardware.nvidia.prime = {
  #  intelBusId = "PCI:0:2:0";
  #  nvidiaBusId = "PCI:1:0:0";
  #};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define custom groups
  users.groups = {
    plocate = {};
    vboxusers = {
      members = [ "abus" ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.abus = {
    isNormalUser = true;
    description = "Abus";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # OBS Studio
  programs.obs-studio = {
    enable = true;

    # Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-gstreamer
      obs-vaapi
      obs-vkcapture
      wlrobs
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    archipelago
    bintools
    cargo-expand
    cowsay
    curl
    dig
    direnv
    discord
    docker-credential-helpers
    dos2unix
    ffmpeg
    file
    flatpak
    gcc
    ghidra
    git
    git-credential-manager
    gnumake
    hunspell
    hunspellDicts.en_US
    #ida-free
    imhex
    iw
    jq
    kdePackages.kcalc
    libreoffice-qt6-fresh
    libva-utils
    libsecret
    mkcert
    neo-cowsay
    neovim
    nmap
    obsidian
    openssl
    p7zip
    pciutils
    pinentry-qt
    postman
    prismlauncher
    protonvpn-gui
    python313
    ripgrep
    rustup
    rust-analyzer
    sl
    spotify
    sqlite
    taskwarrior3
    #tor-browser
    tmux
    tree
    traceroute
    tshark
    unixtools.xxd
    unrar-wrapper
    vit
    vlc
    whois
    wireshark
    wget
    wl-clipboard
    xdg-utils
    zfs
    zoom-us

    # VS Code extensions
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        dbaeumer.vscode-eslint
        editorconfig.editorconfig
        jnoortheen.nix-ide
        mkhl.direnv
        ms-pyright.pyright
        ms-python.debugpy
        ms-python.python
        ms-toolsai.jupyter
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        vue.volar
      ];
    })
  ];

  # Aliases
  environment.shellAliases = {
    code = "codium";
    la = "ls -A";
    ll = "ls -l";
    llh = "ls -lh";
    lla = "ls -lA";
    llah = "ls -lAh";
    open = "xdg-open";
    vim = "nvim";
  };

  # Environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Enable VirtualBox
  virtualisation.virtualbox = {
    host = {
      enable = true;
      #enableExtensionPack = true;
    };
  };

  # Enable Docker
  virtualisation.docker.enable = true;

  # ZeroTier
  services.zerotierone = {
    enable = true;
  };

  # GPG
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Allow TCP traffic on port 8000 for Python http.server
  networking.firewall.interfaces.wlp0s20f3 = {
    allowedTCPPorts = [
      8000
    ];
  };

  # Allow TCP and UDP traffic on VirtualBox interface
  networking.firewall.interfaces.vboxnet0 = {
    allowedTCPPortRanges = [{
      from = 0;
      to = 65535;
    }];
    allowedUDPPortRanges = [{
      from = 0;
      to = 65535;
    }];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # TODO: enable automatic updates
  #system.autoUpgrade.enable = true;
  #system.autoUpgrade.flags = [
  #  "-I"
  #  "nixos-config=/home/abus/.nixos/system/configuration.nix"
  #];
}
