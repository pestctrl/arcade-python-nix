{
  stdenv,
  python310Packages,
  python310,
  fetchFromGitHub,
  ...
}: let
  pytiled_parser = buildPythonPackage {
    name = "pytiled_parser";
    propagatedBuildInputs = with python310Packages; [
      typing-extensions
      attrs
    ];
    src = fetchFromGitHub {
      repo = "pytiled_parser";
      owner = "pythonarcade";
      rev = "v2.2.0";
      sha256 = "";
    };
  };
in
  stdenv.mkDerivation {
    name = "mazegame";
    src = ./.;

    buildInputs = [
      python310
      (python310Packages.buildPythonPackage {
        name = "arcade";
        propagatedBuildInputs = with python310Packages; [
          pillow
          pyglet
          pymunk
          pytiled_parser
        ];
        src = fetchFromGitHub {
          repo = "arcade";
          owner = "pythonarcade";
          rev = "2.6.17";
          sha256 = "";
        };
      })
    ];
  }
