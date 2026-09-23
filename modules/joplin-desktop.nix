{ ... }:

{
  # NIXPKGS-PIN: Joplin sync rejects clients older than 3.7.0, and nixpkgs still
  # ships 3.6.16 (update pending in NixOS/nixpkgs#562806). Delete this module and
  # its import in common.nix once this prints 3.7 or later:
  #   nix eval --raw --inputs-from . nixpkgs#joplin-desktop.version
  # To bump meanwhile, sha256 is the digest GitHub lists beside the AppImage asset.
  nixpkgs.overlays = [
    (_: prev: {
      joplin-desktop =
        let
          pname = "joplin-desktop";
          version = "3.7.18";
          src = prev.fetchurl {
            url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}.AppImage";
            sha256 = "c7ed7eeb6985621b75f0d09088cd01efc9af7aa2cfa17649ed4a83a75b29aca5";
          };
          contents = prev.appimageTools.extractType2 { inherit pname version src; };
        in
        prev.appimageTools.wrapType2 {
          inherit pname version src;
          extraInstallCommands = ''
            install -Dm444 ${contents}/appimagekit-joplin.desktop $out/share/applications/joplin.desktop
            install -Dm444 ${contents}/joplin.png -t $out/share/pixmaps
            substituteInPlace $out/share/applications/joplin.desktop \
              --replace-fail 'Exec=AppRun' 'Exec=${pname}'
          '';
        };
    })
  ];
}
