"""GTK styling shared by the Imperial desktop panels."""
from pathlib import Path
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GLib, Gtk


def panel(title, width, height):
    window = Gtk.Window(title=title)
    window.set_default_size(width, height)
    window.set_position(Gtk.WindowPosition.CENTER)
    window.set_border_width(16)
    window.get_style_context().add_class("holonet-search")
    window.connect("destroy", Gtk.main_quit)

    def key(_, event):
        if event.keyval == Gdk.KEY_Escape:
            window.close()
            return True
        return False

    window.connect("key-press-event", key)
    provider = Gtk.CssProvider()
    css = Path.home() / ".config/chromebook/quick-settings.css"
    if css.is_file():
        provider.load_from_path(str(css))
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    return window


def heading(text):
    label = Gtk.Label(label=text, xalign=0)
    label.get_style_context().add_class("heading")
    return label
