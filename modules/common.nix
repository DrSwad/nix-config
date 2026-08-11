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

  # User
  users.users.swad = {
    isNormalUser = true;
    description = "Swad";
    extraGroups = [ "wheel" "networkmanager" "video" ];
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

  # Niri config lives in its own file
  imports = [ ./niri-config.nix ];

  # Compressed RAM swap
  zramSwap.enable = true;

  # Packages + fonts
  environment.systemPackages = with pkgs; [ ghostty git vim ];
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
}
