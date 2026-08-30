{ config, lib, pkgs, ... }:

{
  # Nix flakes + unfree
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Networking (per-host hostname is set in the host file)
  networking.networkmanager.enable = true;

  # Locale / time
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Default editor: yazi's built-in "edit" opener runs ${EDITOR:-vi}
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # User
  users.users.swad = {
    isNormalUser = true;
    description = "Swad";
    extraGroups = [ "wheel" "networkmanager" "video" "dialout" ];

    # Treat this user as logged in from boot to shutdown, so /run/user/1000 and
    # systemd --user exist continuously. Without it that tmpfs is torn down when
    # the last session closes, which deletes the tmux socket while the server
    # keeps running — reattaching becomes impossible. Also what lets detached
    # sessions outlive exiting niri.
    linger = true;

    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKX9zPPdXu6yfDNrklOgRm+Hj3Y3Ad5gVTRonvRIwaK swad-personal-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx1hH1EXOBAAKyWDue3jI2KMMlTSUITc9GZE0utgHx7 wp100"
    ];
  };

  # SSH: key-only
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Mosh: roaming/latency-tolerant shell over SSH auth.
  # Opens UDP 60000-61000 via programs.mosh.openFirewall (default true).
  programs.mosh.enable = true;

  # Niri + greeter
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };
  };

  imports = [
    ./niri-config.nix
    ./mouseless.nix
    ./tailscale.nix
    ./tmux.nix
  ];

  # Compressed RAM swap
  zramSwap.enable = true;

  # Packages + fonts
  environment.systemPackages = with pkgs; [
    ghostty
    git
    vim
    yazi
    qutebrowser
  ];
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
