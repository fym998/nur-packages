{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchurl,
  pkg-config,
  meson,
  python3,
  ninja,
  gusb,
  pixman,
  glib,
  gobject-introspection,
  cairo,
  libgudev,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  openssl,
  patchelf,  # 用于修复动态库链接
  unzip,
  nss
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfprint-fpcmoh";
  version = "1.94.6";

  outputs = [ "out" "devdoc" ];

  # 1. 下载 libfprint 源码
  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "libfprint";
    repo = "libfprint";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lDnAXWukBZSo8X6UEVR2nOMeVUi/ahnJgx2cP+vykZ8=";
  };

  # 2. 下载 FPC 专有驱动（来自联想官网）
  fpcDrv = fetchurl {
    url = "https://download.lenovo.com/pccbbs/mobiles/r1slm01w.zip";
    hash = "sha256-xykPKnDUj3vdCb7phVNNNRHsANCRiHsH+Bzx4I90wUU=";
  };

  # 3. 下载 PKGBUILD 中的补丁（可选）
  patches = [
    (fetchurl {
      url = "https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/396.patch";
      hash = "sha256-ahpx6hItGh3MuZlVzHvFgHN8ddrKDTeZvZppXo428+E=";
    })
  ];

  postUnpack = ''
    # 解压 FPC 驱动
    mkdir -p fpc-driver
    unzip -q ${finalAttrs.fpcDrv} -d fpc-driver
  '';

  postPatch = ''
    # 修复脚本 shebang
    patchShebangs \
      tests/test-runner.sh \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh

    # 修改 meson.build 以支持 FPC 驱动
    substituteInPlace meson.build \
      --replace "find_library('fpcbep', required: true)" \
                "find_library('fpcbep', required: true, dirs: '/build/fpc-driver/FPC_driver_linux_27.26.23.39/install_fpc/')"
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
    patchelf  # 用于修复动态库链接
    unzip
  ];

  buildInputs = [
    gusb
    pixman
    glib
    cairo
    libgudev
    openssl
    nss
  ];

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    "-Ddrivers=all"  # 启用所有驱动（包括 FPC）
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    (python3.withPackages (p: with p; [ pygobject3 ]))
  ];

  # 安装 FPC 驱动和 udev 规则
  postInstall = ''
    install -Dm644 /build/fpc-driver/FPC_driver_linux_27.26.23.39/install_fpc/libfpcbep.so $out/lib/libfpcbep.so
    install -Dm644 /build/fpc-driver/FPC_driver_linux_libfprint/install_libfprint/lib/udev/rules.d/60-libfprint-2-device-fpc.rules \
      $out/lib/udev/rules.d/60-libfprint-2-device-fpc.rules

    # 修复 libfprint-2.so 的动态库链接
    patchelf --replace-needed "$(patchelf --print-needed $out/lib/libfprint-2.so | grep fpcbep)" \
             libfpcbep.so \
             $out/lib/libfprint-2.so
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    ninjaCheckPhase

    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://aur.archlinux.org/packages/libfprint-fpcmoh-git";
    description = "libfprint with FPC match-on-host driver (10a5:9800)";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ fym998 ];
  };
})
