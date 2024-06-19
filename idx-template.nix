{pkgs, ...}: 
let 
  flutter = pkgs.fetchzip {
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.2-stable.tar.xz";
    hash = "sha256-1MNsakGh9idMUR8bSDu7tVpZB6FPn6nmtvc+Gi10+SA=";
  };
  
in {
     packages = [
        pkgs.curl
        pkgs.gnutar
        pkgs.xz
        pkgs.git
        pkgs.busybox
    ];

    bootstrap = ''
      cp -rf ${flutter} flutter
      chmod -R u+w flutter
      export HOME=/home/user
      # FLUTTER_HOME=./flutter
      # DART_SDK=./flutter/bin/cache/dart-sdk
      # PATH=./flutter/bin
      export PATH="$PATH":"/home/user/flutter/bin" 
      # ./flutter/bin/flutter doctor -v
      # mkdir -p /tmp/pub-cache/log
      # mkdir -p /tmp/pub-cache/bin
      mkdir -p /home/user/.pub-cache/hosted/pub.dev/
      mkdir -p /home/user/.pub-cache/log
      mkdir -p /home/user/.pub-cache/bin
      # export PUB_CACHE=/tmp/pub-cache # After Create files are here => /home/user/.pub-cache/hosted/pub.dev/serverpod_client-2.0.1/lib/serverpod_client.dart
      export PUB_CACHE=/home/user/.pub-cache
      # export PATH="$PATH":"/tmp/pub-cache/bin"
      # export PATH="$PATH":"/home/user/.pub-cache/bin"
      export PATH="$PATH":"$HOME/.pub-cache/bin"
   
      ./flutter/bin/dart pub global activate serverpod_cli
      serverpod
      LASTDIR=$(dirname "$out")
      mkdir -p "$LASTDIR"
      cd "$LASTDIR" 
      serverpod create "$WS_NAME" # in future mini flag
      # mkdir -p "$out"/.{flutter-sdk,idx}
      # mv flutter "$out/.flutter-sdk/flutter"
      # echo ".flutter-sdk/flutter" >> "$out/.gitignore"
      
      mkdir -p "$out/.idx"
      curl -L -o "$out/.idx/run.sh" "https://raw.githubusercontent.com/mg3994/serverpod/main/run.sh"
      chmod +x "$out/.idx/run.sh"
      # Execute run.sh script
      cd "$out/.idx"
      chmod +x run.sh # no need already set above
      ./run.sh
      # Optionally delete run.sh after execution
      rm run.sh
      # Make dev.nix executable
      chmod +x dev.nix
      # Return to $out directory
      cd "$out"
      
      
      
    '';
}