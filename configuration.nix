# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.kernelPackages = pkgs.linuxPackages_testing;
  #boot.kernelPackages = pkgs.linuxPackages_4_14;
  #boot.kernelPackages = pkgs.linuxPackages_4_15;
  #boot.blacklistedKernelModules = [ "pinctrl-amd" ];
  boot.cleanTmpDir = true;
  #boot.kernelParams = ["processor.max_cstate=1"]; # fix for ryzen freeze?
  #boot.kernel.sysctl = {
  #  "kernel.sysrq" = 1;
  #  "vm.swappiness" = 0;
  #  "fs.inotify.max_user_watches" = "409600";
  #};



  # https://bugs.launchpad.net/linux/+bug/1690085/comments/69
  # https://bugzilla.kernel.org/show_bug.cgi?id=196683
  nixpkgs.config.packageOverrides = pkgs: {
    linux_testing = pkgs.linux_testing.override {
      extraConfig = ''
        RCU_EXPERT y
        RCU_NOCB_CPU y
      '';
    };
  };

  boot.kernelParams = [ "rcu_nocbs=0-15 amd_iommu=on iommu=pt amdgpu.dc=1 pcie_acs_override=downstream,multifunction" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1401,10de:0fba
  '';
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [ "vfio_pci" ];

  boot.kernelPackages = pkgs.linuxPackages_testing;

  services.xserver.videoDrivers = [ "amdgpu" ];




  nix.buildCores = 8;
  nix.maxJobs = 8;

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "ryzen"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
  #  consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Kiev";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git dmenu feh i3lock i3status scrot chromium 
    alacritty tdesktop ranger
  ];

  fonts.fonts = with pkgs; [
    bakoma_ttf
    cantarell_fonts
    corefonts
    dejavu_fonts
    gentium
    inconsolata
    liberation_ttf
    powerline-fonts
    terminus_font
    ubuntu_font_family
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  sound.mediaKeys.enable = true;
  #powerManagement.enable = true;
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
 # services.xserver = {
 #   #videoDrivers = ["amdgpu"];
 #   dpi = 120;
 #   autorun = true;
 #   enable = true;
 #   layout = "macintosh_vndr/us";
 #   desktopManager.plasma5.enable = true;
 #   displayManager.lightdm.enable = true;
 #   displayManager.sessionCommands = ''
 #       # HiDPI
 #       export GDK_SCALE=2
 #       export GDK_DPI_SCALE=0.335
 #     '';

 #     # Enable touchpad support.
 #     libinput = {
 #       enable = true;
 #       accelSpeed = "0.25";
 #       clickMethod = "clickfinger";
 #       middleEmulation = false;
 #       naturalScrolling = true;
 #       tapping = false;
 #     };

 #   windowManager.i3 = {
 #     enable = true;
 #   };
 # };

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.paul = {
    isNormalUser = true;
    name = "paul";
    extraGroups = [ "wheel" ];
    uid = 1000;
  };
  
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.nixos.stateVersion = "18.09"; # Did you read the comment?

}
