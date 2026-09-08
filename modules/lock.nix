{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.swaylock ];

  # swaylock authenticates via PAM, and PAM denies any service with no
  # /etc/pam.d entry. Without this the correct password is rejected with
  # "pam_authenticate failed: invalid credentials", and since the locker is
  # already covering the screen, the only way out is a TTY.
  security.pam.services.swaylock = { };
}
