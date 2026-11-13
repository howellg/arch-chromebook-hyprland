# Imperial Command login screen

This SDDM theme uses the Imperial bridge from the Galactic Security lock
screen. It provides username and password fields, a desktop session selector,
and the power actions offered by SDDM.

Install from the repository root with:

```sh
sudo bash themes/starwars/sddm/install.sh
```

The installer places the theme in `/usr/share/sddm/themes/imperial-command`
and selects it using `/etc/sddm.conf.d/90-imperial-command.conf`. The running
SDDM service picks up the change on the next reboot. An explicit `Current`
theme in `/etc/sddm.conf` can override the drop-in.

To restore the previous login theme, remove
`/etc/sddm.conf.d/90-imperial-command.conf` as root and reboot.
