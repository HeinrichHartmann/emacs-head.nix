# Emacs Head Builds

This repository contains nix-files that package emacs@head from https://github.com/emacs-mirror/emacs with the following flags enabled:

1. `--with-json`
2. `--with-natove-compilation`

## emacs-override.nix

This file uses the nixpkgs provided derivations, and makes the necessary adjustments
using the override, overrideAttrs functions defined by nixpkgs.

Usage:
```
nix-env -f emacs-override.nix -iA emacs-head
```

A non-graphical version: `emacs-head-nox` is provided as well.

## emacs-from-scratch.nix

This file is a self-contained emacs build, that only depends on library derivations provided by
nixpkgs. It's the result of a refactoring of the nixpkg emacs definitions, that specializes
to the following environments:

1. Linux: non-graphical build ("nox")
2. Darwin: graphical build using (`--with-ns`).

Usage:
```
nix-env -f emacs-from-scratch.nix -i
```
