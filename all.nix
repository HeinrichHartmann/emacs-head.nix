with (import <nixpkgs> {});
{

  emacs27 = callPackage ./27.nix {
    # use override to enable additional features
    libXaw = xorg.libXaw;
    Xaw3d = null;
    gconf = null;
    alsa-lib = null;
    acl = null;
    gpm = null;
    inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;
    inherit (darwin) sigtool;
  };

}
