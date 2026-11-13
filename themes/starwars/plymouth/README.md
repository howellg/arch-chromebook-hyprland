# Imperial Startup boot splash

A crimson scan illuminates the Imperial insignia before the command
wordmark fades in. Plymouth hands off to the existing SDDM service.

On the Arch Chromebook, run from the repository root.

```sh
sudo pacman -S --needed plymouth
sudo bash themes/starwars/plymouth/install.sh
```

The installer builds and verifies an initramfs before activating it. It
adds the splash flag to the existing Arch boot entries and saves a GRUB
drop-in for future menu regeneration.

To undo the first installation, restore `grub.cfg` and
`initramfs-linux.img` to `/boot/grub/` and `/boot/` respectively, using the
backup directory printed by the installer. Remove
`/etc/mkinitcpio.conf.d/95-imperial-startup.conf` and
`/etc/default/grub.d/95-imperial-startup.cfg` and restore
`/etc/plymouth/plymouthd.conf` from the backup, if present. On subsequent
installs the backup contains copies of any existing drop-ins.
