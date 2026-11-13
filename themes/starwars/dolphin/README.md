# Imperial Databank for Dolphin

Close Dolphin and run from the repository root.

```sh
python3 themes/starwars/dolphin/install.py --vault "/path/to/vault"
```

The installer sets the Dolphin color scheme and adds Places icons for
Downloads, Projects, and any existing folders supplied with `--vault`.
Repeat the argument for multiple vaults. Existing bookmarks keep their names.

The installer prints the location of its backups. To undo the changes,
close Dolphin and restore `dolphinrc` and `user-places.xbel` to their XDG
config and data locations, respectively.
