{ config, lib, ... }:

let
  share = server: export: {
    device = "${server}:${export}";
    fsType = "nfs";
    options = [
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=300"
      "x-systemd.mount-timeout=5"
      "nofail"
      "soft"
      "timeo=5"
      "retrans=2"
      "noatime"
    ];
  };
in

{
  fileSystems = {
    "/mnt/files"  = share "192.168.1.216" "/mnt/data/files";
    "/mnt/music"  = share "192.168.1.221" "/mnt/data/music";
    "/mnt/images" = share "192.168.1.212" "/mnt/data/images";
    "/mnt/videos" = share "192.168.1.218" "/mnt/data/videos";
  };
}
