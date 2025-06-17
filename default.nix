{
  python310Packages,
  fetchFromGitHub,
  fetchPypi,
  fetchzip,
  libGL,
  libGLU,
  glibc,
  xorg,
  fontconfig,
  freetype,
  openal,
  gtk2-x11,
  libpulseaudio,
  gdk-pixbuf,
  ffmpeg-full,
  harfbuzz,
  stdenv,
  lib,
  pkgs,
  ...
}: let
  myPymunk = python310Packages.pymunk.overrideAttrs (attrs: rec {
    pname = "pymunk";
    version = "6.9.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-dl98VhqFmhtWW8UXpHzDmS1iWOhg+RdMUzAzwhivY8M=";
    };
  });
  myPyglet = python310Packages.pyglet.overrideAttrs (attrs: rec {
    pname = "pyglet";
    version = "2.1.5";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-mKBN15occoJaLAZ738ukeKbXDiiS0G7pWmOtgu/Z8QM=";
    };

    postPatch =
    let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      cat > pyglet/lib.py <<EOF
      import ctypes
      def load_library(*names, **kwargs):
          for name in names:
              path = None
              if name == 'GL':
                  path = '${libGL}/lib/libGL${ext}'
              elif name == 'EGL':
                  path = '${libGL}/lib/libEGL${ext}'
              elif name == 'GLU':
                  path = '${libGLU}/lib/libGLU${ext}'
              elif name == 'c':
                  path = '${glibc}/lib/libc${ext}.6'
              elif name == 'X11':
                  path = '${xorg.libX11}/lib/libX11${ext}'
              elif name == 'gdk-x11-2.0':
                  path = '${gtk2-x11}/lib/libgdk-x11-2.0${ext}'
              elif name == 'gdk_pixbuf-2.0':
                  path = '${gdk-pixbuf}/lib/libgdk_pixbuf-2.0${ext}'
              elif name == 'Xext':
                  path = '${xorg.libXext}/lib/libXext${ext}'
              elif name == 'fontconfig':
                  path = '${fontconfig.lib}/lib/libfontconfig${ext}'
              elif name == 'freetype':
                  path = '${freetype}/lib/libfreetype${ext}'
              elif name[0:2] == 'av' or name[0:2] == 'sw':
                  path = '${lib.getLib ffmpeg-full}/lib/lib' + name + '${ext}'
              elif name == 'openal':
                  path = '${openal}/lib/libopenal${ext}'
              elif name == 'pulse':
                  path = '${libpulseaudio}/lib/libpulse${ext}'
              elif name == 'Xi':
                  path = '${xorg.libXi}/lib/libXi${ext}'
              elif name == 'Xinerama':
                  path = '${xorg.libXinerama}/lib/libXinerama${ext}'
              elif name == 'Xxf86vm':
                  path = '${xorg.libXxf86vm}/lib/libXxf86vm${ext}'
              elif name == 'harfbuzz':
                  path = '${harfbuzz}/lib/libharfbuzz${ext}'
              if path is not None:
                  return ctypes.cdll.LoadLibrary(path)
          raise Exception("Could not load library {}".format(names))
      EOF
    '';
  });

  pytiled_parser = python310Packages.buildPythonPackage rec {
    pname = "pytiled_parser";
    version = "2.2.9";
    pyproject = true;
    propagatedBuildInputs = with python310Packages; [
      typing-extensions
      attrs
      pillow
      myPyglet
      myPymunk
    ];

    nativeBuildInputs = [
      python310Packages.setuptools
    ];

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-IlJp/dN6/LzTt26j4sq2sedCOHAnEGBVmQ20P9dFHr0=";
    };

    doCheck = false;
    dontCheckRuntimeDeps = false;
  };
in
(python310Packages.buildPythonPackage {
  name = "arcade";
  pyproject = true;

  nativeBuildInputs = [
    python310Packages.setuptools
  ];

  propagatedBuildInputs = with python310Packages; [
    pillow
    myPymunk
    myPyglet
    pytiled_parser
  ];

  DYLD_LIBRARY_PATH = "${lib.makeLibraryPath [libGL]}";
  src = fetchFromGitHub {
    repo = "arcade";
    owner = "pythonarcade";
    rev = "3.3.0";
    sha256 = "sha256-kSK81H2uRKnO4+RCJiBSUWe3zF3NuFC0wK0cD6jRZEg=";
  };
  doCheck = false;
})
