{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  git,
  gtk-doc,
  gobject-introspection,
  patchelf,
  libgusb,
  pixman,
  nss,
  systemd,
}:
stdenv.mkDerivation rec {
  pname = "libfprint-fpcmoh";
  version = "1.94.6";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "libfprint";
    repo = "libfprint";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
  };

  fpcbep = fetchurl {
    url = "https://download.lenovo.com/pccbbs/mobiles/r1slm01w.zip";
    hash = "sha256-c7290f2a70d48f7bdd09bee985534d3511ec00d091887b07f81cf1e08f74c145";
  };

  patch = fetchurl {
    url = "https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/396.patch";
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # Replace with actual hash
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    git
    gtk-doc
    gobject-introspection
    patchelf
  ];

  buildInputs = [
    libgusb
    pixman
    nss
    systemd
  ];

  postUnpack = ''
    mkdir -p source/FPC_driver_linux_libfprint
    unzip ${fpcbep} -d source/FPC_driver_linux_libfprint
    cp source/FPC_driver_linux_libfprint/install_libfprint/lib/libfpcbep.so source/libfpcbep.so
  '';

  patches = [patch];

  postPatch = ''
    substituteInPlace meson.build \
      --replace "find_library('fpcbep', required: true)" \
                "find_library('fpcbep', required: true, dirs: meson.current_source_dir())"
  '';

  mesonFlags = [
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
  ];

  postInstall = ''
    install -Dm644 ${./FPC_driver_linux_libfprint/install_libfprint/lib/udev/rules.d/60-libfprint-2-device-fpc.rules} \
      $out/lib/udev/rules.d/60-libfprint-2-device-fpc.rules
    install -Dm755 libfpcbep.so $out/lib/libfpcbep.so

    libfpcbep_needed=$(patchelf --print-needed $out/lib/libfprint-2.so | grep libfpcbep)
    patchelf --replace-needed "$libfpcbep_needed" "libfpcbep.so" $out/lib/libfprint-2.so
  '';

  meta = with lib; {
    description = "libfprint with proprietary FPC match on host device 10a5:9800 driver";
    homepage = "https://fprint.freedesktop.org/";
    license = licenses.lgpl21;
    platforms = ["x86_64-linux"];
    maintainers = []; # Add your maintainer handle if needed
  };
}
