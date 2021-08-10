with rec {
  pkgs = import <nixpkgs> {};
};

{
  emacs-head-nox = pkgs.stdenv.mkDerivation {
    name = "emacs-head";
    src = pkgs.fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "4d439744685b6b2492685124994120ebd1fa4abb";
      sha256 = "00vxb83571r39r0dbzkr9agjfmqs929lhq9rwf8akvqghc412apf";
    };
    # for --native-compilation
    NATIVE_FULL_AOT = "1";
    LIBRARY_PATH = "${pkgs.stdenv.cc.libc}/lib";

    buildInputs = [
      pkgs.autoconf pkgs.texinfo pkgs.ncurses # --without-all
      pkgs.gnutls pkgs.pkg-config # normal build
      pkgs.jansson # --with-json
      pkgs.zlib pkgs.libgccjit # --with-native-compilation
    ];

    postPatch = pkgs.lib.concatStringsSep "\n" [
      ''
    for makefile_in in $(find . -name Makefile.in -print); do
      substituteInPlace $makefile_in --replace /bin/pwd pwd
    done
    substituteInPlace src/Makefile.in --replace 'RUN_TEMACS = ./temacs' 'RUN_TEMACS = env -i ./temacs'
    substituteInPlace lisp/international/mule-cmds.el --replace /usr/share/locale ${pkgs.gettext}/share/locale
    ''
    ];
    preConfigure = "./autogen.sh";
    configureFlags = [ "--with-json" "--with-native-compilation" ];
  };
}
