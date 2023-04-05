{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  nativeBuildInputs = [
    nodejs
    yarn
  ];

  shellHook = ''
    export PATH=$PWD/node_modules/.bin:$PWD/packages/backend/node_modules/.bin:$PWD/packages/frontend/node_modules/.bin:$PATH
  '';
}
