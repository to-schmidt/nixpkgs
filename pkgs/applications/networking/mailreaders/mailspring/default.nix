{ stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, glib
, nss
, gtk3
, xorg
, alsaLib
, db
, libkrb5
, libsecret
, udev
, coreutils
, openssl
}:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "mailspring";
  version = "1.7.5";

  src = fetchurl {
    url = "https://github.com/Foundry376/Mailspring/releases/download/${version}/mailspring-${version}-amd64.deb";
    sha256 = "07g614v6a9nwz7hm5vwfnc9lwjvnqvxgw2w5sj7di7b4irf69297";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    glib
    nss
    gtk3
    xorg.libXtst
    xorg.libXScrnSaver
    xorg.libxkbfile
    alsaLib
    db
    libkrb5
    libsecret
  ];

  runtimeDependencies = [
    openssl
    coreutils
    udev.lib
  ];

  unpackPhase = /* sh */ ''
    dpkg -x $src .
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/{bin,lib}
    cp -ar ./usr/share $out

    substituteInPlace $out/share/mailspring/resources/app.asar.unpacked/mailsync \
      --replace realpath ${coreutils.out}/bin/realpath
    substituteInPlace $out/share/mailspring/resources/app.asar.unpacked/mailsync \
      --replace dirname ${coreutils.out}/bin/dirname

    ln -s $out/share/mailspring/mailspring $out/bin/mailspring
    ln -s ${openssl.out}/lib/libcrypto.so $out/lib/libcrypto.so.1.0.0
  '';

  postFixup = /* sh */ ''
    substituteInPlace $out/share/applications/mailspring.desktop \
      --replace /usr/bin $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A beautiful, fast and maintained fork of Nylas Mail by one of the original authors";
    longDescription = ''
      Mailspring is an open-source mail client forked from Nylas Mail and built with Electron.
      Mailspring's sync engine runs locally, but its source is not open.
    '';
    license = licenses.gpl3;
    maintainers = with maintainers; [ toschmidt ];
    homepage = https://getmailspring.com;
    platforms = [ "x86_64-linux" ];
  };
}
