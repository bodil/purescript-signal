{ pkgs ? import <nixpkgs> {} }:

let
  easy-ps = import ./easy-ps.nix { inherit pkgs; };

in pkgs.stdenv.mkDerivation {
  name = "nerg";
  buildInputs = easy-ps.buildInputs;
}
