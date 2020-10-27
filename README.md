# nix-sgx-sdk
Experimental nix derivation for Intel's SGX SDK.

This a work-in-progress.

## Quick start
Build the image and work in a container:

```shell
$ docker-compose build
$ docker-compose run --rm nix-sgx-sdk
```

Build and install the SGX SDK (this will take some time):

```shell
bash-4.4# nix-build shell.nix

...

Installation is successful! The SDK package can be found in /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk

Please set the environment variables with below command:

source /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/environment
/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx
```

The sdk is also under `/usr/src/result`:

```shell
bash-4.4# ls result/sgxsdk/
SampleCode  bin  buildenv.mk  environment  include  lib64  licenses  pkgconfig  sdk_libs  uninstall.sh
```

Source the SGX SDK environment:
```shell
bash-4.4# source result/sgxsdk/environment
```

Let's build a signed enclave, for the `SampleEnclave` example:

```shell
bash-4.4# cd result/sgxsdk/SampleCode/SampleEnclave
```

In order to use `make` we need to go into a `nix-shell` session because `make`
is not installed on the system.

```shell
bash-4.4# nix-shell /usr/src/shell.nix
SGX SDK enviroment
```

Build the signed enclave:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# make enclave.signed.so
GEN  =>  Enclave/Enclave_t.h
CC   <=  Enclave/Enclave_t.c
CXX  <=  Enclave/Edger8rSyntax/Arrays.cpp
CXX  <=  Enclave/Edger8rSyntax/Functions.cpp
CXX  <=  Enclave/Edger8rSyntax/Pointers.cpp
CXX  <=  Enclave/Edger8rSyntax/Types.cpp
CXX  <=  Enclave/Enclave.cpp
CXX  <=  Enclave/TrustedLibrary/Libc.cpp
CXX  <=  Enclave/TrustedLibrary/Libcxx.cpp
CXX  <=  Enclave/TrustedLibrary/Thread.cpp
LINK =>  enclave.so
<EnclaveConfiguration>
    <ProdID>0</ProdID>
    <ISVSVN>0</ISVSVN>
    <StackMaxSize>0x40000</StackMaxSize>
    <HeapMaxSize>0x100000</HeapMaxSize>
    <TCSNum>10</TCSNum>
    <TCSPolicy>1</TCSPolicy>
    <!-- Recommend changing 'DisableDebug' to 1 to make the enclave undebuggable for enclave release -->
    <DisableDebug>0</DisableDebug>
    <MiscSelect>0</MiscSelect>
    <MiscMask>0xFFFFFFFF</MiscMask>
</EnclaveConfiguration>
tcs_num 10, tcs_max_num 10, tcs_min_pool 1
The required memory is 4059136B.
The required memory is 0x3df000, 3964 KB.
Succeed.
SIGN =>  enclave.signed.so
```

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sha256sum enclave.signed.so
4328970ec560704b259a301979f0c4963718b0a4e55d313cce070d2589dfdd0b  enclave.signed.so
```

Compile and run the local attestation sample in simulation mode:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode]# cd LocalAttestation/
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation]# make SGX_MODE=SIM

...

LINK => libenclave_responder.so
<EnclaveConfiguration>
    <ProdID>1</ProdID>
    <ISVSVN>0</ISVSVN>
    <StackMaxSize>0x40000</StackMaxSize>
    <HeapMaxSize>0x100000</HeapMaxSize>
    <TCSNum>1</TCSNum>
    <TCSPolicy>1</TCSPolicy>
    <!-- Recommend changing 'DisableDebug' to 1 to make the enclave undebuggable for enclave release -->
    <DisableDebug>0</DisableDebug>
    <MiscSelect>0</MiscSelect>
    <MiscMask>0xFFFFFFFF</MiscMask>
</EnclaveConfiguration>
tcs_num 1, tcs_max_num 1, tcs_min_pool 1
The required memory is 1994752B.
The required memory is 0x1e7000, 1948 KB.
Succeed.
SIGN =>  libenclave_responder.signed.so
make[1]: Leaving directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/EnclaveResponder'
make[1]: Entering directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/App'
CC   <=  EnclaveInitiator_u.c
CC   <=  EnclaveResponder_u.c
CC   <=  UntrustedEnclaveMessageExchange.cpp
CXX   <=  App.cpp
GEN  =>  app
make[1]: Leaving directory '/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/SampleCode/LocalAttestation/App'
The project has been built in simulation debug mode.
```

Run the app:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation]# cd bin/
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation/bin]# ./app
succeed to load enclaves.
succeed to establish secure channel.
Succeed to exchange secure message...
Succeed to close Session...
```

The same commands can be used with the other samples.
