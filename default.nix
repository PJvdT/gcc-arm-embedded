{ lib
, stdenvNoCC
, fetchgit
, ncurses5
, zlib
, git
, gmp
, mpfr
, libmpc
, bison
, flex
, gcc6
#, binutils-arm-embedded
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "gcc-arm-embedded";
  version = "4.7";
  target = "arm-none-eabi";
  target-cpu = "cortex-m4";


  suffix = {
    x86_64-linux  = "x86_64_arm-linux";
  }.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  src = fetchgit {
    url = "git://gcc.gnu.org/git/gcc.git";
    rev = "911595bf2d485c0d1e067d9a94a867d9b8281502";
    sha256 = {
      x86_64-linux  = "sha256-7lx32YAb5kxSYKD5R6qGMgyGaW4A1YNfZGOvjmT9MRU=";
    }.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");    
  };

  output = [ "out" "lib" "man" "info" ]; 

  dontPatchELF = true;
  dontStrip = true;

#  buildInputs = [ git zlib gmp mpfr libmpc binutils-arm-embedded ];
  buildInputs = [ gcc6 git zlib gmp mpfr libmpc bison flex ];

  configurePhase = ''
      ./configure --target=${target} --prefix=$out \
                  --with-cpu=${target-cpu} --enable-languages=c,c++ \
                  --without-headers --with-glibc \
                  --with-no-thumb-interwork --with-mode=thumb --disable-werror 
  '';

  patches = [ ./0001-fix-compiler-errors.patch ];
  patchPhase = ''
      patch -p1 < ../0001-fix-compiler-errors.patch
  '';

  buildPhase = ''
      make  all-gcc 2>&1 | tee ./binutils-build-logs.log
  '';

  installPhase = ''
      make  install-gcc 2>&1 | tee ./binutils-build-logs.log
  '';

  env = {
     CFLAGS="-Wno-error";
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
