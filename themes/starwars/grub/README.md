# Imperial Command GRUB menu

This GRUB theme uses the Coruscant bridge artwork from Galactic Security and
the SDDM login screen. It adds a crimson selection bar and an autoboot
countdown while retaining the system's boot entries and timeout.

On the Chromebook, run from the repository root:

```sh
sudo bash themes/starwars/grub/install.sh
```

The installer uses GRUB, librsvg, and the JetBrains Mono Nerd Font installed
on the Chromebook. It places the theme on the boot partition and loads it
through a managed block in `/boot/grub/custom.cfg`. The existing generated
boot menu and timeout stay in place. Reboot to view the theme.

To revert, restore `custom.cfg` from the backup directory printed by the
installer. If the backup directory is empty, the installer created the file
and you can remove `/boot/grub/custom.cfg` as root. If you have since added
custom settings, remove only the lines from `# BEGIN Imperial Command theme`
through `# END Imperial Command theme`.
