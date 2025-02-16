# No user-configurable parameters
{ pkgs, ... }: {
  packages = [ 
    pkgs.jdk17
    pkgs.unzip
    pkgs.dart
    pkgs.flutter
    pkgs.android-sdk
    pkgs.android-studio
    pkgs.android-tools
    pkgs.gradle
  ];

  env = {
    ANDROID_HOME = "$HOME/android-sdk";
    ANDROID_SDK_ROOT = "$HOME/android-sdk";
    ANDROID_AVD_HOME = "$HOME/.android/avd";
  };
  
  # Shell script that produces the final environment
  bootstrap = ''
    # Copy the folder containing the `idx-template` files to the final
    # project folder for the new workspace. ${./.} inserts the directory
    # of the checked-out Git folder containing this template.
    cp -rf ${./.} "$out"

    # Set some permissions
    chmod -R +w "$out"

    # Remove the template files themselves and any connection to the template's
    # Git repository
    rm -rf "$out/.git" "$out/idx-template".{nix,json}

    echo "⚙️ Instalando dependencias de Flutter..."
    flutter doctor
    flutter pub get

    echo "⚙️ Configurando Android SDK y creando AVD..."
    mkdir -p $ANDROID_HOME
    sdkmanager "platform-tools" "platforms;android-34" "system-images;android-34;google_apis;x86_64"
  '';
}
