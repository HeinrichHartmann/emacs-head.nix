with rec {
  emacs-overlay = import (builtins.fetchTarball { url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz; });
  pkgs = import <nixpkgs> { overlays = [ emacs-overlay ]; };
};

pkgs.emacsGcc.override {
  withX = false;
  withGTK2 = false;
  withGTK3 = false;
}
