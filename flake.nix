{
  description = "Cut&Run development environment";

  inputs = {
    # Specify the Nixpkgs input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = builtins.currentSystem; #"x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
    };
  in {
    devShells.${system} = {
      default = pkgs.mkShell {
        name = "impurePythonEnv";
        venvDir = "./.venv";

        # Add your package dependencies here
        buildInputs = with pkgs; [
          # for downloading files
          docker
          git
          curl
          git
          gzip
          # for nextflow
          bedops
          bedtools
          bowtie2
          deeptools
          jdk22
          macs2
          meme-suite
          perl
          picard-tools
          samtools
          trimmomatic

          R
          # A Python interpreter including the 'venv' module is required to bootstrap
          # the environment.
          python3Packages.python

          # This execute some shell code to initialize a venv in $venvDir before
          # dropping into the shell
          python3Packages.venvShellHook

          # Those are dependencies that we would like to use from nixpkgs, which will
          # add them to PYTHONPATH and thus make them accessible from within the venv.
          python3Packages.numpy
          python3Packages.pandas
          python3Packages.scipy
          python3Packages.scikit-learn
          python3Packages.requests
          python3Packages.torch
          python3Packages.torchvision
          python3Packages.hyperopt
          python3Packages.matplotlib
          python3Packages.wxPython_4_2
          python3Packages.setuptools

          # In this particular example, in order to compile any binary extensions they may
          # require, the Python modules listed in the hypothetical requirements.txt need
          # the following packages to be installed locally:
          taglib
          liblinear
          openssl
          git
          libxml2
          libxslt
          libzip
          zlib
          libstdcxx5
          stdenv.cc.cc.lib
          bash
          wget
          zlib

          cargo
        ];

        LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";

        # Run this command, only after creating the virtual environment
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
        '';

        # Now we can execute any commands within the virtual environment.
        # This is optional and can be left out to run pip manually.
        postShellHook = ''
          # allow pip to install wheels
          unset SOURCE_DATE_EPOCH
          # fixes libstdc++ issues and libgl.so issues
          LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
        '';
      };
    };
  };
}
