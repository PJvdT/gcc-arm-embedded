{
  description = "gcc-arm-linux-embedded-4.7.3";

  inputs = {
      nixpkgs.url = github:nixos/nixpkgs?ref=nixos-23.05;
#      binutils-arm-embedded.url = github.com:PJvdT/binutils-arm-embedded?ref=REL_2_24;      
  };

  outputs = { 
    self, 
    nixpkgs ,
  }: let
     system = "x86_64-linux" ;
     pkgs = import nixpkgs { inherit system; };
#     binutils-arm-embedded = import binutils-arm-embedded {inherit system; };
  in {
     packages.${system} = {
         gcc-arm-embedded-4 = pkgs.callPackage ./. {};
         default = self.packages.${system}.gcc-arm-embedded-4;
     };
  };
}