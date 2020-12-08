# nix-sgx-sdk
Experimental nix derivation for Intel's SGX SDK.

This a work-in-progress.

## Quick start
Build the image:

```shell
$ docker-compose build
```

Note that this will take some time as this will build the SGX SDK installer
and install it under `/usr/src/result`.

You should see something similar to at the end of the build:

```shell
$ docker-compose build

...

Installation is successful! The SDK package can be found in /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk

Please set the environment variables with below command:

source /nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx/sgxsdk/environment
/nix/store/rfh0lambk582hmxc9kb9wks7bw1jd4nz-sgx
```

NOTE that The SDK is also under the more convenient path `/usr/src/result`.

See this for yourself:

```shell
$ docker-compose run --rm nix-sgx-sdk
```

```shell
bash-4.4# ls result/sgxsdk/
SampleCode  bin  buildenv.mk  environment  include  lib64  licenses  pkgconfig  sdk_libs  uninstall.sh
```

Source the SGX SDK environment:
```shell
bash-4.4# source result/sgxsdk/environment
```

Let's build and a sign an enclave, for the `SampleEnclave` example:

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

Check the hash of the `enclave.so` file:

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sha256sum enclave.so
00c8533ff8e0be9c03fa58b69deac89b8c54af2e48782957562fd2d866112b86  enclave.so
```

For the signed enclave, one has to follow steps based on
[Verify Intel(R) Prebuilt AE Reproducibility](https://github.com/intel/linux-sgx/tree/master/linux/reproducibility/ae_reproducibility_verifier). (See work-in-progress example under
https://github.com/initc3/nix-sgx-sdk/tree/rust-sgx-sdk#audit-case-comparing-two-signed-enclaves
for the time being.) A brief example, which checks the "private-key-independent" and
"time-independent" metadata is shown below.

```shell
# check the "private-key-independent" and "time-independent" metadata aka
# "partial metadata"
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# $SGX_SDK/bin/x64/sgx_sign dump -enclave enclave.signed.so -dumpfile metadata.txt
Succeed.

[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sed -n '/metadata->magic_num/,/metadata->enclave_css.header.module_vendor/p;/metadata->enclave_css.header.header2/,/metadata->enclave_css.header.hw_version/p;/metadata->enclave_css.body.misc_select/,/metadata->enclave_css.body.isv_svn/p;' metadata.txt > partial_metadata.txt

[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sha256sum partial_metadata.txt
8f349074773701017b3eeb2e1603df88aff02c31fb3ad51b06a7367ab414f310  partial_metadata.txt
```

```shell
# NOTE that this is not reproducible as the message signed depends on the date. But
# if you try it on the same day (UTC) it should be reproducible. Below it's just an
# an example (2020.12.07).
[nix-shell:/usr/src/result/sgxsdk/SampleCode/SampleEnclave]# sha256sum enclave.signed.so
de2a88e478da28267f077d0631e7f247e08af7966d4c5603e90128ed6915231c  enclave.signed.so
```

### Running an app in simulation mode
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

```shell
[nix-shell:/usr/src/result/sgxsdk/SampleCode/LocalAttestation/bin]# sha256sum app
03325cae23ecb64672ad63b17d406ae0039c8d87e26573ed37b8183ba7991a8d  app
```

The same commands can be used with the other samples.
