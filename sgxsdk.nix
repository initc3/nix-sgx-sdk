{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

let
  ipp_crypto = fetchurl {
    url ="https://download.01.org/intel-sgx/sgx-linux/2.12/optimized_libs_update_2.12.tar.gz";
    sha256 = "367bd7b9579f0d418aeba2467c9c75a17f2e4e84a7d0a688e1ef8367aa4da0a4";
  };

  asldobjdump = import ./asldobjdump.nix {
    inherit bison fetchurl flex gettext libbfd libiberty libopcodes stdenv texinfo zlib;
  };

in
stdenvNoCC.mkDerivation {
  inherit ipp_crypto asldobjdump;
  name = "sgx";
  src = fetchFromGitHub {
    owner = "sbellem";
    repo = "linux-sgx";
    rev = "6b5ba77dbba16d30cf9db21d92ff5d87d155c4b7";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 6b5ba77dbba16d30cf9db21d92ff5d87d155c4b7 sbellem linux-sgx
    sha256 = "0a0n4zgsxipaa0dxas4zmwmm3las2in7i616vxkb20v5g3nq1wk9";
    fetchSubmodules = true;
  };
  postUnpack = ''
    tar -C $sourceRoot -xvf $ipp_crypto
    '';
  dontConfigure = true;
  preBuild = ''
    export BINUTILS_DIR=$asldobjdump/bin
  '';
  buildInputs = [
    asldobjdump
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
    /nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27
    gcc8
    texinfo
    bison
    flex
    perl
    python3
    which
    git
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
