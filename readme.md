## System Installation

This is my personalized guide for installation, so I didn't forget how to install it and hopefully not wasting my time reading more documentations

```text
Installation: archinstall
Bootloader: grub
WindowManager: hyprland
Greeter: ly
Packages: grub, efibootmgr, vim
```

Don't forget to carry over the network settings

After installation do arch-chroot into your system
Run this command so BIOS able to see the grub (UEFI)

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable
grub-mkconfig -o /boot/grub/grub.cfg
```

After those you're good to exit arch-chroot and reboot the system

## System Setup

Rebinding keyboard keys with **keyd** package, config stored at `/etc/keyd/default.conf` and run the **keyd** service

## Hyprland Setup

Hyprland are split into multiple packages:

- Hyprland system config files `/.config/hypr/hyprland.conf`
- Hyprpaper wallpaper config files `/.config/hypr/hyprpaper.conf`

## Application Setup

The application that are in use

- Terminal **kitty**, config files `/.config/kitty/kitty.conf`
- Application launcher **wofi**, config folder `/.config/wofi`
- Taskbar **waybar**, config folder `/.config/waybar`