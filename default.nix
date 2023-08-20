{ lib
, stdenv
, fetchgit
, ncurses5
, zlib
, git
, gmp
, mpfr
, libmpc
#, binutils-arm-embedded
, ...
}:

stdenv.mkDerivation rec {
  pname = "gcc-arm-embedded";
  version = "4.7";
  target = "arm-none-eabi";
  target-cpu = "coretex-m4";

  suffix = {
    x86_64-linux  = "x86_64_arm-linux";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  src = fetchgit {
    url = "git://gcc.gnu.org/git/gcc.git";
    rev = "911595bf2d485c0d1e067d9a94a867d9b8281502";
    sha256 = {
      x86_64-linux  = "sha256-7lx32YAb5kxSYKD5R6qGMgyGaW4A1YNfZGOvjmT9MRU=";
    }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");    
  };

## output = [ "out"  ]; 
  output = [ ];

  dontPatchELF = true;
  dontStrip = true;

#  buildInputs = [ git zlib gmp mpfr libmpc binutils-arm-embedded ];
  buildInputs = [ git zlib gmp mpfr libmpc ];

  configurePhase = ''
      export PATH=$PATH:/nix/store/16hhvdjl0c7z2zindhg3jzy4r7bfh22d-binutils-arm-embedded-2.24/bin
      ./configure --target=${target} --prefix=$out/ \
                  --with-cpu=${target-cpu} --disable-werror \
                  --enable-languages=c,c++ --without-headers --with-glibc \
                  --with-no-thumb-interwork --with-mode=thumb
  '';

  buildPhase = ''
      export PATH=$PATH:/nix/store/16hhvdjl0c7z2zindhg3jzy4r7bfh22d-binutils-arm-embedded-2.24/bin
      make  all-gcc 2>&1 | tee ./binutils-build-logs.log
  '';

  installPhase = ''
      export PATH=$PATH:/nix/store/16hhvdjl0c7z2zindhg3jzy4r7bfh22d-binutils-arm-embedded-2.24/bin
      make  install-gcc 2>&1 | tee ./binutils-build-logs.log
  '';

  env = {

     MY_RVDT_GCC_PATH="/home/ronald/src/toolchain/build/binutils-build/result/bin"; 
     _PATH="/home/ronald/src/toolchain/build/binutils-build/result/bin";
     DIRENV_DISABLE="true";
  } ; 

  meta = with lib; {
    description = "Build GNU toolchain from ARM Cortex-M & Cortex-R processors";
    homepage = "https://developer.arm.com/open-source/gnu-toolchain/gnu-rm";
    license = with licenses; [ bsd2 gpl2 gpl3 lgpl21 lgpl3 mit ];
    maintainers = with maintainers; [ Ronald ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
