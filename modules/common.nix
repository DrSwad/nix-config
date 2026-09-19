{ pkgs, ... }:

{
  imports = [
    ./claude-code.nix
    ./home-manager.nix
    ./mouseless.nix
    ./niri.nix
    ./remotes.nix
    ./tailscale.nix
  ];

  # Nix flakes + unfree
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Networking (per-host hostname is set in the host file)
  networking.networkmanager.enable = true;

  # Locale / time
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Login shell registration only — the configuration lives in home/modules/shell.nix.
  # enableGlobalCompInit off because HM's zsh module runs compinit itself.
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  # User
  users.users.swad = {
    isNormalUser = true;
    description = "Swad";
    extraGroups = [ "wheel" "networkmanager" "video" "dialout" ];
    shell = pkgs.zsh;
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKX9zPPdXu6yfDNrklOgRm+Hj3Y3Ad5gVTRonvRIwaK swad-personal-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx1hH1EXOBAAKyWDue3jI2KMMlTSUITc9GZE0utgHx7 wp100"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLz3t1Yrgdbh/XGllJDsUHeu94joyx+5B/Os4QaFKmL ipad-mini"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQ4GtZKoYGp7tqTYuzT2WweQVB+731A/r1ov61DyV5Z wasif-lab-pc"
    ];

    # Treat this user as logged in from boot to shutdown, so /run/user/1000 and
    # systemd --user exist continuously. Without it that tmpfs is torn down when
    # the last session closes, which deletes the tmux socket while the server
    # keeps running — reattaching becomes impossible. Also what lets detached
    # sessions outlive exiting niri.
    linger = true;
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
  environment.variables.MOSH_SERVER_NETWORK_TMOUT = "86400";

  # Compressed RAM swap
  zramSwap.enable = true;

  # System-wide: everything user-facing lives in home/modules/packages.nix.
  environment.systemPackages = with pkgs; [ vim ];
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
