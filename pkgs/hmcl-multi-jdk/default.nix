{
  hmcl,
  jdk17,
  jdk21,
  jdks ? [
    jdk17
    jdk21
  ],
  makeDesktopItem,
}:
hmcl.overrideAttrs (finalAttrs: {
  pname = "hmcl-multi-jdk";
  meta = finalAttrs.meta // {
    description = "Custom HMCL with multiple JDK support";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "HMCL";
      exec = "env PATH=$PATH:${map (jdk: "${jdk}/bin/java") jdks} hmcl";
      icon = "hmcl";
      comment = finalAttrs.meta.description;
      desktopName = "HMCL";
      categories = [ "Game" ];
    })
  ];
})
