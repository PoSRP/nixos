{ username, ... }:

{
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/home/${username}/workspace" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@workspace" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@var-log" "noatime" ];
  };

  fileSystems."/swap" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" ];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" "noatime" ];
  };
}
