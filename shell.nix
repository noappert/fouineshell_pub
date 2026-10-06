{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.git
    pkgs.vala
    pkgs.pkg-config
    pkgs.glib
    pkgs.libsoup_3
    pkgs.json-glib
    pkgs.glib-networking
  ];

shellHook = ''
    unset CPATH
    unset C_INCLUDE_PATH
    unset CPLUS_INCLUDE_PATH
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
  '';
}
