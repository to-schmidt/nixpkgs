{ stdenv
, fetchzip
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook
, makeDesktopItem
, udev
, alsaLib
, gtk3
, glib
, nss
, dbus
, xorg
}:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "keeweb";
  version = "1.14.0";

  src = fetchzip {
    url = "https://github.com/keeweb/keeweb/releases/download/v${version}/KeeWeb-${version}.linux.x64.zip";
    sha256 = "1vs9jfpb8g04hf7wm7h1agg9lq74shsn1mlp09a15jdbz65gssi9";
    stripRoot = false;
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ 
    autoPatchelfHook 
  ];

  buildInputs = [ 
    glib
    nss
    dbus
    gtk3
    alsaLib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXtst
    xorg.libXScrnSaver
  ];

  runtimeDependencies = [
    udev.lib
  ];

  installPhase = ''
    mkdir -p $out/share/keeweb/
    cp -R $src/* $out/share/keeweb/

    mkdir -p $out/bin
    ln -s $out/share/keeweb/keeweb $out/bin/keeweb
  '';

  desktopItem = makeDesktopItem {
    name = "keeweb";
    exec = "keeweb";
    icon = "keeweb";
    desktopName = "KeeWeb";
    genericName = "Password Manager";
    categories = "Application;";
    comment = "Free cross-platform password manager compatible with KeePass";
  };

  meta = with stdenv.lib; {
    homepage = "https://keeweb.info/";
    description = "Free cross-platform password manager compatible with KeePass";
    license = licenses.mit;
    maintainers = with maintainers; [ toschmidt ];
    platforms = platforms.linux;
  };
}