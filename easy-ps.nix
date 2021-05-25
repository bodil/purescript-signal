    { pkgs ? import <nixpkgs> {} }:
    
    import (pkgs.fetchFromGitHub {
        owner = "justinwoo";
        repo = "easy-purescript-nix";
        rev = "47507b27e15a9c3b929111cf43d2e9c0e4b97f4c";
        sha256 = "0gnwymgm4i5y9vknpcsr99pwy76w14nclqxb6xmmzlw2s8fx85hm";
    }) { inherit pkgs; }
