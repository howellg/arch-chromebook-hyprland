# Imperial Command GRUB menu

This GRUB theme uses the Coruscant bridge artwork from Galactic Security and
the SDDM login screen. It adds a crimson selection bar and an autoboot
countdown while retaining the system's boot entries and timeout.

On the Chromebook, run from the repository root:

```sh
sudo bash themes/starwars/grub/install.sh
```

The installer uses GRUB, librsvg, and the JetBrains Mono Nerd Font installed
on the Chromebook. It builds the theme, backs up the existing boot
configuration under `/var/backups/grub-imperial.*`, and uses
`/etc/default/grub.d/99-imperial-command.cfg` to select the theme. It validates
the candidate menu before activating it and stops if the regenerated boot
entries differ. Reboot to view the theme.

To revert a first installation, remove
`/etc/default/grub.d/99-imperial-command.cfg` and restore `grub.cfg` from the
backup directory printed by the installer. If the backup directory also
contains `99-imperial-command.cfg`, restore that file to the drop-in path.
The previous menu is usable with the unused theme assets still in place.
