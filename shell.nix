{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs { }}:
with pkgs;

let
  ipp_crypto = fetchurl {
    url = "https://download.01.org/intel-sgx/sgx-linux/2.11/optimized_libs_2.11.tar.gz";
    sha256 = "43ad0859114c1e78a4381a9bd6a03929499c0e1b268cc7f719e9b65e53127162";
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
    rev = "4f3ec1dd89e06efbc6ebd2a8ef85eb1a7ded3130";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev 4f3ec1dd89e06efbc6ebd2a8ef85eb1a7ded3130 sbellem linux-sgx
    sha256 = "08f3divshmc644xdbzlm2v4wvmkj6sik07pi60d1cr1zga888khf";
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
    echo -e 'no\n'$out | ./linux/installer/bin/sgx_linux_x64_sdk_2.11.100.2.bin
    '';

  dontFixup = true;
  shellHook = ''echo "SGX SDK enviroment"'';
}
