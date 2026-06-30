<h1 align="center">My NixOS desktop</h1>

<p align="center">
  My personal NixOS flake for a Hyprland desktop across a couple ThinkPads and a QEMU test target
</p>

<p align="center">
  <a href="https://github.com/PoSRP/nixos/actions/workflows/vm-boot.yaml">
    <img alt="VM Boot" src="https://github.com/PoSRP/nixos/actions/workflows/vm-boot.yaml/badge.svg">
  </a>
  <img alt="NixOS" src="https://img.shields.io/badge/NixOS-25.11-5277C3?style=flat&logo=nixos&logoColor=white">
  <img alt="Hyprland" src="https://img.shields.io/badge/Hyprland-Wayland-58E1FF?style=flat">
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue?style=flat">
  </a>
</p>

<p align="center">
  <it>There's always a lot left to do</it>
</p>

---

<div align="center">

| Host                | Role         |
|---------------------|--------------|
| `thinkpad-x13-gen1` | Daily-driver |
| `thinkpad-w540`     | Backup       |
| `qemu-desktop`      | Throwaway VM |

</div>

## Screenshots

*To come, it's not really a polished UI*

## Repo config

Needs a PAT for the flake workflow

- `pull-requests:rw`
- `content:rw`

## Updating

Updating should be as easy as (immediate forced reboot):

```sh
nixhelp update
```

If you have to roll back a generation:

```sh
nixhelp rollback
```

## Testing

If just a few packages is wanted in the terminal:

```sh
nixhelp try <packages ...>
```

If the test can work in a QEMU VM use:

```sh
./scripts/vm
```

If the test should run on an already working system:

```sh
nixhelp test <PR-123>
# OR
nixhelp test <origin-branch>
```

And if you need to test with a reboot (immediate forced reboot):

```sh
nixhelp test --reboot <PR-123>
```

## Installing from USB

Build the ISO:

```sh
./scripts/build-iso
```

Flash it to a USB drive:

```sh
./scripts/flash-usb /dev/sdX
```

Boot it and run the install script:

```sh
sudo /iso/config/scripts/install
```

Reboot once the install is completed.  
Finally connect to some network and run the post-install script (or don't):

```sh
./workspace/nixos/scripts/post-install
```
