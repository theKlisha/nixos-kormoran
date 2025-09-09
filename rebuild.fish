#!/opt/homebrew/bin/fish

nix run nixpkgs#nixos-rebuild -- \
  --target-host root@10.0.199.255 \
  --build-host root@10.0.199.255 \
  --flake .#kormoran \
  --use-remote-sudo \
  --fast \
  switch
