{
  description = "NS-3 toolkit for compiling";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
    bake_home = builtins.toString ./bake;

    # packageOverrides = pkgs.callPackage ./pythonPackages.nix {};
    # python = pkgs.python3.override { inherit packageOverrides; };
  in
  {
      devShells."x86_64-linux".default = pkgs.mkShell {
        packages = with pkgs; [
          # (python.withPackages (ps: [
          #   ps.cppyy-cling
          # ]))
          # base
          git
          unzip
          gnumake
          gnupatch
          gcc
          gnutar
          python312
          python312Packages.pip
          cmake

          # required by bake
          python312Packages.distro
          python312Packages.requests
          automake

          # requirede by ns-3
          python312Packages.mercurial

          # python312Packages.pyqt5
          # libsForQt5.full
          # libsForQt5.qt5.qtbase
          # qtcreator
          # for pygobject
          # cairo
          # gobject-introspection
          # gobject-introspection-unwrapped
        ];

        shellHook = ''
          # For installing pip packages as discussed in 
          export PIP_PREFIX=$(pwd)/_build/pip_packages
          export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
          export PATH="$PIP_PREFIX/bin:$PATH"
          unset SOURCE_DATE_EPOCH

          pip install -r requirements.txt

          # For working globally with bake
          cd bake
          export PATH=$PATH:${bake_home}/build/bin
        '';

        BAKE_HOME = bake_home;
        PYTHONPATH = "${bake_home}/build/lib";
        LD_LIBRARY_PATH = "${bake_home}/build/lib";
      };
  };
}
