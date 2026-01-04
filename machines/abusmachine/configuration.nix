{ lib, pkgs, ... }:
let
  nix-vscode-extensions-src = import (
    builtins.fetchGit {
      url = "https://github.com/nix-community/nix-vscode-extensions";
      ref = "refs/heads/master";
      rev = "eab8555d49df1ebc5be412face4a3e6852588e82";
    }
  );
  nix-vscode-extensions = nix-vscode-extensions-src.extensions.x86_64-linux;
  resetLicense =
    drv:
    drv.overrideAttrs (prev: {
      meta = prev.meta // {
        license = [ ];
      };
    });
  # Evil hack to allow this unfree extension without globally allowing unfree everything
  # https://github.com/nix-community/nix-vscode-extensions#unfree-extensions
  visualstudiotoolsforunity-vstuc = resetLicense nix-vscode-extensions.vscode-marketplace.visualstudiotoolsforunity.vstuc;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/users/abus.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow emulating other architectures
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  # UEFI firmware support
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nixpkgs settings
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.strings.getName pkg) [
    # List of allowed unfree packages
    "corefonts"
    "discord"
    "nvidia-settings"
    "nvidia-x11"
    "obsidian"
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

  # Enable nix-ld
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    icu
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
  networking.hostName = "abusmachine";

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
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  services.xserver.videoDrivers = [ "intel" ];

  # Scanner config
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # Enable sound with pipewire.
  #services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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
      obs-livesplit-one
      obs-pipewire-audio-capture
      obs-vaapi
      obs-vkcapture
      wlrobs
    ];
  };

  environment.systemPackages = with pkgs; [
    archipelago
    bintools
    cargo
    cargo-expand
    cowsay
    curl
    dig
    direnv
    discord
    docker-credential-helpers
    dos2unix
    element-desktop
    ffmpeg
    file
    flatpak
    gcc
    ghidra
    git
    git-credential-manager
    godotPackages_4_5.godot
    gnumake
    hunspell
    hunspellDicts.en_US
    imhex
    iw
    jq
    kdePackages.kcalc
    libreoffice-qt6-fresh
    libresplit
    libva-utils
    libsecret
    mkcert
    neo-cowsay
    neovim
    nmap
    obs-cmd
    obsidian
    openssl
    p7zip
    pciutils
    pinentry-qt
    pinta
    postman
    prismlauncher
    protonvpn-gui
    python313
    qemu
    quickemu
    ripgrep
    rust-analyzer
    rustc
    sl
    spotify
    sqlite
    taskwarrior3
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
      vscodeExtensions = with nix-vscode-extensions.open-vsx; [
        angular.ng-template
        dbaeumer.vscode-eslint
        dioxuslabs.dioxus
        editorconfig.editorconfig
        jnoortheen.nix-ide
        mkhl.direnv
        ms-pyright.pyright
        ms-python.debugpy
        ms-python.python
        ms-toolsai.jupyter
        vadimcn.vscode-lldb
        ziglang.vscode-zig
      ] ++ [
        visualstudiotoolsforunity-vstuc
        vscode-extensions.rust-lang.rust-analyzer
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

  # Allow TCP traffic on port 8000 for Python http.server
  networking.firewall.interfaces.wlp0s20f3 = {
    allowedTCPPorts = [
      8000
      25565
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

  # Automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flags = [
    "-I"
    "nixos-config=/home/abus/.nixos/machines/abusmachine/configuration.nix"
  ];
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.rebootWindow = {
    lower = "04:00";
    upper = "07:00";
  };

  specialisation = {
    gpu.configuration = {
      system.nixos.tags = [ "gpu" ];
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.open = true;
      hardware.nvidia.modesetting.enable = true;

      boot.initrd.availableKernelModules = [
        "nvidia_drm" "nvidia_modeset" "nvidia" "nvidia_uvm"
      ];

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
      };
    };
  };
}
