"""GTK styling shared by the Imperial desktop panels."""
import json
from pathlib import Path
import subprocess
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GLib, Gtk

REVEAL_US = 190_000


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
    window.connect("show", reveal)
    provider = Gtk.CssProvider()
    css = Path.home() / ".config/chromebook/quick-settings.css"
    if css.is_file():
        provider.load_from_path(str(css))
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    return window


def animations_enabled():
    settings = Gtk.Settings.get_default()
    if settings is None or not settings.get_property("gtk-enable-animations"):
        return False
    try:
        raw = subprocess.check_output(["hyprctl", "getoption", "animations:enabled", "-j"],
                                      stderr=subprocess.DEVNULL, timeout=0.15)
        return json.loads(raw).get("bool") is True
    except (OSError, ValueError, subprocess.SubprocessError):
        return False


def reveal(window):
    """Sweep a pass-through shutter over the panel's content on its first show."""
    content = window.get_child()
    if content is None or getattr(window, "_galactic_reveal_done", False):
        return
    window._galactic_reveal_done = True
    if not animations_enabled():
        return

    import gi
    gi.require_foreign("cairo")
    overlay = Gtk.Overlay()
    window.remove(content)
    overlay.add(content)
    window.add(overlay)
    shutter = Gtk.DrawingArea(hexpand=True, vexpand=True)
    overlay.add_overlay(shutter)
    overlay.set_overlay_pass_through(shutter, True)
    started = None
    progress = 0.0

    def draw(widget, cr):
        width = widget.get_allocated_width()
        height = widget.get_allocated_height()
        edge = width * (1 - (1 - progress) ** 2)
        cr.set_source_rgb(.048, .066, .104)
        cr.rectangle(edge, 0, width - edge, height)
        cr.fill()
        cr.set_source_rgba(.94, .49, .52, (1 - progress) * .82)
        cr.rectangle(edge, 0, 2, height)
        cr.fill()
        return False

    def tick(widget, clock):
        nonlocal started, progress
        now = clock.get_frame_time()
        if started is None:
            started = now
        progress = min(1.0, (now - started) / REVEAL_US)
        if progress == 1.0:
            overlay.remove(widget)
            return GLib.SOURCE_REMOVE
        widget.queue_draw()
        return GLib.SOURCE_CONTINUE

    shutter.connect("draw", draw)
    shutter.add_tick_callback(tick)
    overlay.show()
    shutter.show()


def heading(text):
    label = Gtk.Label(label=text, xalign=0)
    label.get_style_context().add_class("heading")
    return label
