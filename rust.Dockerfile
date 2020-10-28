FROM initc3/nix-sgx-sdk@sha256:9bf0a404c54cf4c41facd5135989810c38b3029a02ea01f7f331e14ca214da22

COPY asldobjdump.nix /usr/src/asldobjdump.nix
COPY sgxsdk.nix /usr/src/sgxsdk.nix
COPY rust-sgx-sdk.nix /usr/src/rust-sgx-sdk.nix
COPY nix /usr/src/nix

WORKDIR /usr/src
RUN nix-shell rust-sgx-sdk.nix
