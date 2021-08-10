# Emacs Head Builds

This repository contains several different nix files, that all build/install the
latest emacs version from https://github.com/emacs-mirror/emacs with the
following flags enabled:

1. `--with-json`
2. `--with-natove-compilation`

**Warning:** To actually pull the latest version, the `src` entries in the files have to be updated.

For more information and background see: https://www.heinrichhartmann.com/posts/2021-08-08-nix-into/

## emacs-from-scratch.nix

A stand-alone nix derivation, was built up from scratch, relying on nixpkgs only for dependencies.

Usage:
```
nix-env -f emacs-from-scratch.nix -iA emacs-head-nox
```

## emacs-refactored.nix

This is a stand-alone nix derivation, that only relyies on nixpkgs for dependencies. It was build by
refactoring nixpkgs' emacs package into a stand-alone file, and then applying the necessary changes
to pull the latest source and fix the build: 

Usage:
```
nix-env -f emacs-refactored.nix -iA emacs-head
```

This will install the graphical version on OSX and a `--without-x` version on Linux. 

## emacs-override.nix

This file uses the nixpkgs provided emacs derivation, and makes the necessary adjustments using the
override, overrideAttrs functions defined by nixpkgs.

Usage:
```
nix-env -f emacs-override.nix -iA emacs-head     # graphical version
nix-env -f emacs-override.nix -iA emacs-head-nox # non-graphical version
```

This is the most complete/usable of the provided alternatives.

## emacs-overlay.nix

This is a stand-alone nix file, that leverages the community maintained
https://github.com/nix-community/emacs-overlay/ to build the latest emacs with native compilation
support.

```
nix-env -f emacs-overlay.nix -iA emacs-head     # graphical version
nix-env -f emacs-overlay.nix -iA emacs-head-nox # non-graphical version
```

This version does not need manual updates of the `src` attribute to stay up-to-date.
