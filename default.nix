{
  python310Packages,
  fetchFromGitHub,
  fetchzip,
  unstablePymunk,
  unstablePillow,
  libGL,
  lib,
  ...
}: let
  pytiled_parser = python310Packages.buildPythonPackage {
    name = "pytiled_parser";
    propagatedBuildInputs = with python310Packages; [
      typing-extensions
      attrs
    ];
    src = fetchFromGitHub {
      repo = "pytiled_parser";
      owner = "pythonarcade";
      rev = "v2.2.0";
      sha256 = "sha256-28OJI9dVz14/FRI+2E51ZLs13FsQdSh3tQ5Irz24HAs=";
    };
  };
  myPyglet = python310Packages.buildPythonPackage rec {
    pname = "pyglet";
    version = "2.0.dev23";
    src = fetchzip {
      url = "https://files.pythonhosted.org/packages/dc/25/865361d60671e79e3e4f1fc7846750fd88fd7dd3c59fb8c410eda3f14a07/pyglet-2.0.dev23.zip";
      sha256 = "sha256-QeQnmMdzeeLv8EsK6J10ihJ1k3jpckjMImOrHPclQxo=";
    };

    doCheck = false;
  };
in (python310Packages.buildPythonPackage {
  name = "arcade";
  propagatedBuildInputs = with python310Packages; [
    unstablePillow
    unstablePymunk
    pytiled_parser
    myPyglet
  ];
  DYLD_LIBRARY_PATH = "${lib.makeLibraryPath [libGL]}";
  src = fetchFromGitHub {
    repo = "arcade";
    owner = "pythonarcade";
    rev = "2.6.17";
    sha256 = "sha256-Et1zOnjNoHajshhDajAG3vVunQmzQ2tWgGp+m+4Rkdc=";
  };
  doCheck = false;
})
