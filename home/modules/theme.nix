{ ... }:

{
  # Served by the portal as org.freedesktop.appearance color-scheme.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # GTK3 ignores color-scheme. Not set for gtk4: libadwaita warns on it.
  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  # NIXPKGS-PIN: with this unset, Qt in nixpkgs 26.05 reports ColorScheme.Unknown
  # on niri and stays light. After bumping, recheck with the variable unset.
  home.sessionVariables.QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
}
