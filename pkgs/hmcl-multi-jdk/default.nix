{
  lib,
  hmcl,
  jdk17,
  jdk21,
  hmclJdk ? jdk17,
  jdks ? [
    jdk17
    jdk21
  ],
  hmclWithJdk ? hmcl.override {
    jre = hmclJdk;
  },
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:
hmclWithJdk.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "hmcl-multi-jdk";

    desktopItems = previousAttrs.desktopItems or [ ] ++ [
      (makeDesktopItem {
        name = "HMCL Multi-JDK";
        exec = "hmcl-multi-jdk";
        icon = "hmcl";
        comment = finalAttrs.meta.description;
        desktopName = "HMCL Multi-JDK";
        categories = [ "Game" ];
      })
    ];

    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
      makeWrapper
      copyDesktopItems
    ];

    postFixup =
      previousAttrs.postFixup or ""
      + ''
        makeWrapper ${hmcl}/bin/hmcl $out/bin/hmcl-multi-jdk \
          --prefix PATH : "${lib.makeBinPath jdks}"
      '';

    meta = hmcl.meta // {
      mainProgram = "hmcl-multi-jdk";
    };
  }
)
