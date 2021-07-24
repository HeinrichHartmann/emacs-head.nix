with (import <nixpkgs> {});
let
  file27_nix = import ./generic.nix (rec {
    version = "27.2";
    sha256 = "sha256-tKfMTnjmPzeGJOCRkhW5EK9bsqCvyBn60pgnLp9Awbk=";
    patches = fetchpatch: [
      ./tramp-detect-wrapped-gvfsd.patch
      (fetchpatch {
        name = "fix-aarch64-darwin-triplet.patch";
        url = "https://git.savannah.gnu.org/cgit/emacs.git/patch/?id=a88f63500e475f842e5fbdd9abba4ce122cdb082";
        sha256 = "sha256-RF9b5PojFUAjh2TDUW4+HaWveV30Spy1iAXhaWf1ZVg=";
      })
    ];
  });
in
{
  emacs27 = callPackage file27_nix {
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
