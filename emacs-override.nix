with (import <nixpkgs> {});

{
  emacs-head = (emacs-nox.overrideAttrs (old : {
    pname = "emacs";
    version = "head";
    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "4d439744685b6b2492685124994120ebd1fa4abb";
      sha256 = "00vxb83571r39r0dbzkr9agjfmqs929lhq9rwf8akvqghc412apf";
    };
    patches = [];
    configureFlags = old.configureFlags ++ ["--with-json"];
    preConfigure = "./autogen.sh";
    buildInputs = old.buildInputs ++ [ autoconf texinfo ];
  })).override {
    nativeComp = true;
  };

  emacs-head-nox = (emacs-nox.overrideAttrs (old : {
    pname = "emacs-nox";
    version = "head";
    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "4d439744685b6b2492685124994120ebd1fa4abb";
      sha256 = "00vxb83571r39r0dbzkr9agjfmqs929lhq9rwf8akvqghc412apf";
    };
    patches = [];
    configureFlags = old.configureFlags ++ ["--with-json"];
    preConfigure = "./autogen.sh";
    buildInputs = old.buildInputs ++ [ autoconf texinfo ];
  })).override {
    nativeComp = true;
  };
}
