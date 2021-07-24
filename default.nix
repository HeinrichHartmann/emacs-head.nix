with (import <nixpkgs> {});
{
  emacs27-nox = lowPrio (appendToName "nox" (emacs27.override {
   withX = false;
   withNS = false;
   withGTK2 = false;
   withGTK3 = false;
  }));
}
