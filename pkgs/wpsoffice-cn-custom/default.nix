{
  wpsoffice-cn,
}:
wpsoffice-cn.overrideAttrs (previousAttrs: {
  pname = "wpsoffice-cn-custom";
  postInstall =
    (previousAttrs.postInstall or "")
    + ''
      for i in $out/share/applications/*;do
        substituteInPlace $i \
          --replace Exec= "Exec=env XMODIFIERS=\"@im=fcitx\" GTK_IM_MODULE=\"fcitx\" QT_IM_MODULE=\"fcitx\" SDL_IM_MODULE=fcitx GLFW_IM_MODULE=ibus "
      done
    '';
})
