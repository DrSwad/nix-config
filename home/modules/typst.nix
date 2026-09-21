{ pkgs, ... }:

{
  home.packages = [
    # NIXPKGS-PIN: versioned attrs, so each version here must equal the one in
    # the deck's `#import "@preview/<name>:<version>"`; bump both together.
    # Imports not listed here fail to resolve rather than falling back to a
    # download, since the package cache path is a read-only store path.
    (pkgs.typst.withPackages (p: [
      p.touying_0_7_3
      p.cetz_0_5_0
    ]))
    pkgs.pympress
    pkgs.zathura
  ];
}
