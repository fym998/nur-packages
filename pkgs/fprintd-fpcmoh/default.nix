{ pkgs, ... }:
{
  fprintd-fpcmoh =
    pkgs.fprintd.overrideAttrs
      (finalAttrs: {
        pname = "fprintd-fpcmoh";
        version = "1.94.4";
        src = fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "libfprint";
          repo = "fprintd";
          rev = "v${finalAttrs.version}";
          sha256 = "sha256-B2g2d29jSER30OUqCkdk3+Hv5T3DA4SUKoyiqHb8FeU=";
        };
      }).override
      { libfprint = pkgs.callPackage ../libfprint-fpcmoh { }; };
}
