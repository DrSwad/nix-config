{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
  ];

  # Boot (UEFI, systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Machine identity
  networking.hostName = "swad-lab-pc";

  # Timezone
  time.timeZone = "America/Phoenix";

  # NVIDIA (RTX 6000 Ada -> open kernel modules)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # efibootmgr for boot-order management
  environment.systemPackages = with pkgs; [ efibootmgr ];

  system.stateVersion = "26.05";
}
