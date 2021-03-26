{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

let
  ipp_crypto = fetchurl {
    url ="https://download.01.org/intel-sgx/sgx-linux/2.13/optimized_libs_2.13.tar.gz";
    sha256 = "a24fd428147afffb86030c34743e8cb9532f7d4847e44e85fd9e43031d4f0359";
  };
  #asldobjdump = import ./asldobjdump.nix {
  #  inherit bison fetchurl flex gettext libbfd libiberty libopcodes stdenv texinfo zlib;
  #};

  # for binutils 2.35.1
  unstablepkgs = import (builtins.fetchGit {
    name = "nixpkgs-unstable";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "bed08131cd29a85f19716d9351940bdc34834492";
  }) {};
  binutils235 = unstablepkgs.binutils;

  # for glibc 2.27
  pkgs1809 = import (builtins.fetchGit {
    name = "nixos-18.09";
    #url = "https://github.com/NixOS/nixpkgs/";
    #ref = "refs/heads/nixpkgs-18.03-darwin";
    #rev = "72c48fef2ffd757b27b4ceab1787c1f9de1d20a1";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixos-18.09";
    rev = "fc98b4e129a66d2829ccfa07ead4d569eb88ffa6";
  }) {};
  glibc227 = pkgs1809.glibc;

in
stdenvNoCC.mkDerivation {
  #inherit ipp_crypto asldobjdump;
  inherit ipp_crypto binutils235 glibc227;
  #inherit ipp_crypto binutils235;
  name = "sgx";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    #rev = "6b5ba77dbba16d30cf9db21d92ff5d87d155c4b7";
    rev = "5cec833b7e7db0181b90fbf5403315fb0ce75f3e";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 6b5ba77dbba16d30cf9db21d92ff5d87d155c4b7 sbellem linux-sgx
    #sha256 = "0a0n4zgsxipaa0dxas4zmwmm3las2in7i616vxkb20v5g3nq1wk9";
    sha256 = "1jr7c7f26s3hdn2znqydh08jdzl62q6wga76xp83f1fi8pik4lxk";
    fetchSubmodules = true;
  };
  postUnpack = ''
    tar -C $sourceRoot -xvf $ipp_crypto
    '';
  dontConfigure = true;
  preBuild = ''
    export BINUTILS_DIR=$binutils235/bin
  '';
  #export BINUTILS_DIR=$asldobjdump/bin
  buildInputs = [
    #asldobjdump
    binutils235
    autoconf
    automake
    libtool
    ocaml
    ocamlPackages.ocamlbuild
    file
    cmake
    gnum4
    openssl
    gnumake
    # FIXME For now, must get glibc from another nixpkgs revision.
    # See https://github.com/intel/linux-sgx/issues/612
    #glibc
    glibc227
    #/nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27
    gcc8
    texinfo
    bison
    flex
    perl
    python3
    # TODO is this needed?
    which
    # TODO is this needed?
    git
    # TODO is this needed?
    protobuf
  ];
  propagatedBuildInputs = [ gcc8 ];
  buildFlags = ["sdk_install_pkg"];
  dontInstall = true;
  postBuild = ''
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_*.bin
    '';

  dontFixup = true;
  shellHook = ''echo "SGX SDK enviroment"'';
}
