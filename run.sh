#!/bin/bash

# Get the current directory
current_dir=$(dirname "$(pwd)")

# Create the content of the dev.nix file
cat <<EOF > dev.nix

  # To learn more about how to use Nix to configure your environment
  # see: https://developers.google.com/idx/guides/customize-idx-env
  {pkgs}:
  let
    flutterProjectDir = "${current_dir}/${current_dir##*/}_flutter"; # Define your Flutter project directory here
    serverProjectDir = "${current_dir}/${current_dir##*/}_server"; # Define your Laravel project directory here
    clientProjectDir = "${current_dir}/${current_dir##*/}_client"; # Define your Client project directory here
  in 
  {
    # Which nixpkgs channel to use.
    channel = "stable-23.11"; # or "unstable"
    # Use https://search.nixos.org/packages to find packages
    packages = [
      pkgs.nodePackages.firebase-tools
      pkgs.jdk17
      pkgs.unzip
      
    ];
    # Sets environment variables in the workspace
    env = {};
    services.docker.enable = true;
    idx = {
      # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
      extensions = [
        "usernamehw.errorlens"
        "Dart-Code.flutter"
        "Dart-Code.dart-code"
        "serverpod.serverpod"
        # "vscodevim.vim"
        
      ];

      workspace = {
        # Runs when a workspace is first created with this \`dev.nix\` file
       
        onCreate = {
          set-path-emul = ''
            #  cd \${flutterProjectDir}/android # you can't echo but just in case
            dart pub global activate serverpod_cli
            export PATH="\$PATH":"\$HOME/.pub-cache/bin"
            serverpod
            # echo "Switching to Flutter master channel"
            # flutter channel master || { echo "Failed to switch Flutter channel"; exit 1; }
            # flutter upgrade || { echo "Failed to upgrade Flutter"; exit 1; }
            
            # echo "Changing directory to \${flutterProjectDir}/android"

            # cd \${flutterProjectDir}/android || { echo "Failed to change directory"; exit 1; }
            # # As there is no need of this ./gradlew command but we are jsut checking time to build , if it fails don't worry
            # echo "Running gradlew assembleDebug"
            # ./gradlew \\
            #   --parallel \\
            #   -Pverbose=true \\
            #   -Ptarget-platform=android-x86 \\
            #   -Ptarget=\${flutterProjectDir}/lib/main.dart \\
            #   -Pbase-application-name=android.app.Application \\
            #   -Pdart-defines=RkxVVFRFUl9XRUJfQ0FOVkFTS0lUX1VSTD1odHRwczovL3d3dy5nc3RhdGljLmNvbS9mbHV0dGVyLWNhbnZhc2tpdC85NzU1MDkwN2I3MGY0ZjNiMzI4YjZjMTYwMGRmMjFmYWMxYTE4ODlhLw== \\
            #   -Pdart-obfuscation=false \\
            #   -Ptrack-widget-creation=true \\
            #   -Ptree-shake-icons=false \\
            #   -Pfilesystem-scheme=org-dartlang-root \\
            #   assembleDebug

            # TODO: Execute web build in debug mode.
            # flutter run does this transparently either way
            # https://github.com/flutter/flutter/issues/96283#issuecomment-1144750411
            # flutter build web --profile --dart-define=Dart2jsOptimization=O0 
            # cd \${serverProjectDir}
            # docker compose up --build --detach 
            
            adb -s emulator-5554 wait-for-device
          '';
        };
        
        # To run something each time the workspace is (re)started, use the \`onStart\` hook
      # Runs when the workspace is (re)started
      onStart = {
       run-server = ''
          cd \${serverProjectDir}
          dart pub get
          docker compose up --build --detach
          # serverpod language-server # will be handled by VS Code Extension
          cd \${flutterProjectDir}
          flutter pub get
          cd \${clientProjectDir}
          flutter pub get
          cd \${serverProjectDir}
          dart --observe bin/main.dart --apply-migrations
          # dart --observe bin/main.dart # migrations Not Applied Yet , Stop the server then run command mannualy 
       '';
      };
     
      };
      # Enable previews and customize configuration
      previews = {
        enable = true;
        previews = {
       
         
       
          web = {
            cwd = "\${flutterProjectDir}";
            command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "\$PORT" "--web-browser-flag" "--disable-web-security"];
            manager = "flutter";
          };
          # android = {
          #   cwd = "\${flutterProjectDir}";
          #   command = ["flutter" "run" "--enable-experiment=macros"  "--machine" "-d" "android" "-d" "emulator-5554" "--target=\${flutterProjectDir}/lib/main.dart"];
          #   manager = "flutter";
          # };
        };
      };
    };
  }

EOF

# Set the permissions for the file


echo "dev.nix file created => permissions to set."