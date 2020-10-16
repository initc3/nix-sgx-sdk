{bison, fetchurl, flex, gettext, libbfd, libiberty, libopcodes, stdenv, texinfo, zlib }:

let
  name = "binutils";
  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz";
    sha256 = "119g6340ksv1jkg6bwaxdp2whhlly22l9m30nj6y284ynjgna48v";
  };
in

stdenv.mkDerivation {
  inherit name;
  inherit src;
  #name = "binutils";
  #src = fetchurl {
  #  url = "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz";
  #  sha256 = "119g6340ksv1jkg6bwaxdp2whhlly22l9m30nj6y284ynjgna48v";
  #};
  buildInputs = [ bison flex gettext libbfd libiberty libopcodes texinfo zlib ];
  configureFlags = [
    #"--prefix=/usr/local"
    "--enable-shared"
    #"--disable-static"
    "--enable-64-bit-bfd"
    "--with-system-zlib"
    "--disable-werror"
    "--enable-gold"
    "--enable-plugins"
    "--enable-ld=default"
  ];
}
# 9354714ae10eefb7b0cd747efccc9194223b84fe573c8e0d868763f90d0e1d0e  gas/as-new
# 37bc7806d4e896316561f4f29165b990de65139174b03da4618b7efbb7e83eff  ld/ld-new
# 7ae3d0ff7a6aac6b8e2c3d24cb8c7bbee97080c359cab7ba5698596a3a7410eb  binutils/objdump
# 784940d1afbf4bddd082f384fee1e0f8a6d315fa6cf327642bf98cd46166c23d  gold/ld-new
