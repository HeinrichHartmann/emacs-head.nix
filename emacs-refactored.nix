with (import <nixpkgs> {});

{
  emacs-head = (callPackage ({
    stdenv
    , pkg-config
    , autoconf
    , cairo
    , dbus
    , fetchpatch
    , fetchurl
    , gettext
    , giflib
    , gnutls
    , harfbuzz
    , imagemagick
    , jansson
    , lib
    , libXaw
    , libXcursor
    , libXpm
    , libgccjit
    , libjpeg
    , libotf
    , librsvg
    , libselinux
    , libtiff
    , libxml2
    , m17n_lib
    , makeWrapper # native-comp params
    , ncurses
    , targetPlatform
    , texinfo
    , xlibsWrapper
    , AppKit, GSS, ImageIO
    , sigtool
  }:

    let
      backendPath = (lib.concatStringsSep " "
        (builtins.map (x: ''\"-B${x}\"'') [
          # Paths necessary so the JIT compiler finds its libraries:
          "${lib.getLib libgccjit}/lib"
          "${lib.getLib libgccjit}/lib/gcc"
          "${lib.getLib stdenv.cc.libc}/lib"

          # Executable paths necessary for compilation (ld, as):
          "${lib.getBin stdenv.cc.cc}/bin"
          "${lib.getBin stdenv.cc.bintools}/bin"
          "${lib.getBin stdenv.cc.bintools.bintools}/bin"
        ]));
    in

      assert stdenv.isDarwin -> libXaw != null;       # fails to link otherwise

      stdenv.mkDerivation ({
        NATIVE_FULL_AOT = "1";
        LIBRARY_PATH = "${lib.getLib stdenv.cc.libc}/lib";

        pname = "emacs-head";

        src = fetchFromGitHub {
          owner = "emacs-mirror";
          repo = "emacs";
          rev = "4d439744685b6b2492685124994120ebd1fa4abb";
          sha256 = "00vxb83571r39r0dbzkr9agjfmqs929lhq9rwf8akvqghc412apf";
        };
        version = "28.05";

        enableParallelBuilding = true;

        postPatch = lib.concatStringsSep "\n" [
          "rm -fr .git"

          # Reduce closure size by cleaning the environment of the emacs dumper
          ''
               substituteInPlace src/Makefile.in \
                 --replace 'RUN_TEMACS = ./temacs' 'RUN_TEMACS = env -i ./temacs'
            ''
          ''
               substituteInPlace lisp/international/mule-cmds.el \
                 --replace /usr/share/locale ${gettext}/share/locale
               for makefile_in in $(find . -name Makefile.in -print); do
                 substituteInPlace $makefile_in --replace /bin/pwd pwd
               done
            ''
          ''
            # Make native compilation work both inside and outside of nix build
            substituteInPlace lisp/emacs-lisp/comp.el --replace \
             "(defcustom native-comp-driver-options nil" \
             "(defcustom native-comp-driver-options '(${backendPath})"
            ''
        ];

        nativeBuildInputs = [ pkg-config makeWrapper ];

        buildInputs = [ ncurses libxml2 gnutls gettext jansson harfbuzz.dev autoconf texinfo libgccjit ]
                      ++ lib.optionals stdenv.isLinux [ dbus libselinux ]
                      ++ lib.optionals stdenv.isDarwin [ sigtool librsvg AppKit GSS ImageIO imagemagick ];

        preConfigure = "./autogen.sh";

        configureFlags = [
          "--disable-build-details" # for a (more) reproducible build
          "--with-modules"
          "--with-json"
          "--with-native-compilation"
        ]
        ++ lib.optionals stdenv.isLinux [
          "--with-x=no" "--with-xpm=no" "--with-jpeg=no" "--with-png=no" "--with-gif=no" "--with-tiff=no"
        ]
        ++ lib.optionals stdenv.isDarwin [
          "--disable-ns-self-contained" "--with-ns" "--with-imagemagick"
        ];


        installTargets = [ "tags" "install" ];

        postInstall = ''
              mkdir -p $out/share/emacs/site-lisp
              cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el

              $out/bin/emacs --batch -f batch-byte-compile $out/share/emacs/site-lisp/site-start.el

              siteVersionDir=`ls $out/share/emacs | grep -v site-lisp | head -n 1`

              rm -r $out/share/emacs/$siteVersionDir/site-lisp

              echo "Generating native-compiled trampolines..."
              # precompile trampolines in parallel, but avoid spawning one process per trampoline.
              # 1000 is a rough lower bound on the number of trampolines compiled.
              $out/bin/emacs --batch --eval "(mapatoms (lambda (s) \
                (when (subr-primitive-p (symbol-function s)) (print s))))" \
                | xargs -n $((1000/NIX_BUILD_CORES + 1)) -P $NIX_BUILD_CORES \
                  $out/bin/emacs --batch -l comp --eval "(while argv \
                    (comp-trampoline-compile (intern (pop argv))))"
              mkdir -p $out/share/emacs/native-lisp
              $out/bin/emacs --batch \
                --eval "(add-to-list 'native-comp-eln-load-path \"$out/share/emacs/native-lisp\")" \
                -f batch-native-compile $out/share/emacs/site-lisp/site-start.el
              ''
        + lib.optionalString stdenv.isDarwin ''
              mkdir -p $out/Applications
              mv nextstep/Emacs.app $out/Applications
              ln -snf $out/lib/emacs/*/native-lisp $out/Applications/Emacs.app/Contents/native-lisp
              '';

        meta = with lib; {
          description = "The extensible, customizable GNU text editor";
          homepage    = "https://www.gnu.org/software/emacs/";
          license     = licenses.gpl3Plus;
          maintainers = [ "Heinrich Hartmann <heinrich@heinrichhartmann.com" ];
          platforms   = platforms.all;
          longDescription = ''Latest emacs with --json --native-comp'';
        };
      }
      )) {
        libXaw = xorg.libXaw;
        inherit (darwin.apple_sdk.frameworks) AppKit GSS ImageIO;
        inherit (darwin) sigtool;
      });
}
