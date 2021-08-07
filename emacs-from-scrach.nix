with rec {
  pkgs = import <nixpkgs> {};
};

pkgs.stdenv.mkDerivation {
  name = "emacs-head";
  src = pkgs.fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "4d439744685b6b2492685124994120ebd1fa4abb";
      sha256 = "00vxb83571r39r0dbzkr9agjfmqs929lhq9rwf8akvqghc412apf";
  };
  buildInputs = [ pkgs.autoconf pkgs.texinfo pkgs.ncurses pkgs.gnutls pkgs.pkg-config pkgs.jansson ];
  postPatch = pkgs.lib.concatStringsSep "\n" [
    ''
    substituteInPlace src/Makefile.in --replace 'RUN_TEMACS = ./temacs' 'RUN_TEMACS = env -i ./temacs'
    substituteInPlace lisp/international/mule-cmds.el --replace /usr/share/locale ${pkgs.gettext}/share/locale
    for makefile_in in $(find . -name Makefile.in -print); do
      substituteInPlace $makefile_in --replace /bin/pwd pwd
    done
    ''
  ];
  preConfigure = "./autogen.sh";
  configureFlags = [ "--with-json" ];
  enableParallelBuilding = true;
}
