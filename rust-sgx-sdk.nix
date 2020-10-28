let
  sources = import ./nix/sources.nix;
  rust = import ./nix/rust.nix { inherit sources; };
  pkgs = import sources.nixpkgs { };
  sgxsdk = import ./sgxsdk.nix { inherit sources; }; 
in
#pkgs.mkShell {
pkgs.stdenv.mkDerivation {
#pkgs.stdenvNoCC.mkDerivation {
  name = "rust-sgx-sdk";
  inherit sgxsdk;
  src = pkgs.fetchFromGitHub {
    owner = "apache";
    repo = "incubator-teaclave-sgx-sdk";
    rev = "a6a172e652b4db4eaa17e4faa078fda8922abdd0";
    # Command to get the sha256 hash (note the --fetch-submodules arg):
    # nix run -f '<nixpkgs>' nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev a6a172e652b4db4eaa17e4faa078fda8922abdd0 apache incubator-teaclave-sgx-sdk
    sha256 = "1v67fj1n8ygvmvq536js5xsi8009kwgcdpqr4bb372mylaj3mz00";
    fetchSubmodules = true;
  };
  postUnpack = ''
    export SGX_SDK=$sgxsdk/sgxsdk
    source $SGX_SDK/environment
    '';
  preBuild = ''
    cd samplecode/helloworld
    '';
  dontConfigure = true;
  buildInputs = [
    sgxsdk
    rust
    pkgs.bashInteractive
    pkgs.autoconf
    pkgs.automake
    pkgs.libtool
    #pkgs.ocaml
    #pkgs.ocamlPackages.ocamlbuild
    pkgs.file
    #pkgs.cmake
    #pkgs.gnum4
    #pkgs.openssl
    #pkgs.gnumake
    # FIXME For now, must get glibc from another nixpkgs revision.
    # See https://github.com/intel/linux-sgx/issues/612
    #glibc
    #/nix/store/681354n3k44r8z90m35hm8945vsp95h1-glibc-2.27
    #pkgs.gcc8
    #pkgs.texinfo
    #pkgs.bison
    #pkgs.flex
    #pkgs.perl
    #pkgs.python3
    pkgs.which
    #pkgs.git
  ];
  buildFlags = ["bin/enclave.signed.so"];
  dontInstall = true;
}
