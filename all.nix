with (import <nixpkgs> {});
{
  emacs = emacs27;
  emacs-nox = emacs27-nox;

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

  emacs27-nox = lowPrio (appendToName "nox" (emacs27.override {
    withX = false;
    withNS = false;
    withGTK2 = false;
    withGTK3 = false;
  }));
}
