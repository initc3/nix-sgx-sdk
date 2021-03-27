#FROM nixpkgs/nix:nixos-20.09
FROM nixpkgs/nix@sha256:9eee633905248e4800a308a5af38fcb5d58d9505dc6c1268196ae83757843a79

COPY shell.nix /usr/src/shell.nix
COPY sgxsdk.nix /usr/src/sgxsdk.nix
COPY nix /usr/src/nix

WORKDIR /usr/src
RUN nix-build shell.nix
