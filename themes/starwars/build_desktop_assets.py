#!/usr/bin/env python3
"""Build the Imperial XCursor theme and short PipeWire cues from local artwork."""
import math
from pathlib import Path
import struct
import subprocess
import wave

import gi
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf

HOME = Path.home()
ICONS = HOME / ".local/share/icons/ImperialTargeting"
SOUNDS = HOME / ".local/share/starwars-theme/sounds"

ARROW = '<path d="M5 3 26 20l-10 1-4 9z" fill="#d9e3ed" stroke="#10131b" stroke-width="2" stroke-linejoin="round"/><path d="m7 7 12 11-6 1z" fill="#a62f4b"/>'
TARGET = '<path d="M13 5H5v8m14-8h8v8M5 19v8h8m14-8v8h-8M12 16h8m-4-4v8" fill="none" stroke-linecap="square"/>'
RESIZE = '<path d="M6 11V7h20v4M6 21v4h20v-4M5 16h22m-18-4-4 4 4 4m14-8 4 4-4 4" fill="none" stroke-linejoin="round"/>'
COG = '<circle cx="16" cy="16" r="10" fill="#151722" stroke="#d6dce6" stroke-width="2"/><path d="M16 4v5m10-1-4 4m6 6-5-1m-2 10-2-5m-8 5 2-5M4 18l5-1M7 8l4 4" stroke="#ed7775" stroke-width="2"/><circle cx="16" cy="16" r="3" fill="#ed7775"/>'

CURSORS = {
    "left_ptr": (ARROW, (5, 3), ("default", "arrow", "top_left_arrow")),
    "crosshair": (TARGET, (16, 16), ("cross", "tcross")),
    "wait": (COG, (16, 16), ("watch", "progress", "left_ptr_watch")),
    "ew-resize": (RESIZE, (16, 16), ("sb_h_double_arrow", "col-resize", "e-resize", "w-resize",
                                    "left_side", "right_side", "h_double_arrow")),
    "ns-resize": (RESIZE, (16, 16), ("sb_v_double_arrow", "row-resize", "n-resize", "s-resize",
                                    "top_side", "bottom_side", "v_double_arrow")),
    "nwse-resize": (RESIZE, (16, 16), ("nw-resize", "se-resize", "top_left_corner", "bottom_right_corner")),
    "nesw-resize": (RESIZE, (16, 16), ("ne-resize", "sw-resize", "top_right_corner", "bottom_left_corner")),
}


def pixels(art, size, angle):
    if art in (TARGET, RESIZE):
        art = ('<g stroke="#10131b" stroke-width="4">' + art + '</g>'
               '<g stroke="#ed7775" stroke-width="2">' + art + '</g>')
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" '
           f'viewBox="0 0 32 32"><g transform="rotate({angle} 16 16)">{art}</g></svg>')
    png = subprocess.check_output(["rsvg-convert"], input=svg.encode(), timeout=5)
    loader = GdkPixbuf.PixbufLoader.new_with_type("png")
    loader.write(png)
    loader.close()
    image = loader.get_pixbuf()
    data = image.get_pixels()
    out = bytearray()
    for y in range(size):
        for x in range(size):
            offset = y * image.get_rowstride() + x * 4
            r, g, b, a = data[offset:offset + 4]
            out.extend((b * a // 255, g * a // 255, r * a // 255, a))
    return out


def cursor(name, art, hot):
    sizes = (24, 32, 36, 48, 64)
    angles = range(0, 360, 45) if name == "wait" else (
        {"ns-resize": 90, "nwse-resize": 45, "nesw-resize": -45}.get(name, 0),)
    image_type = 0xfffd0002
    frames = [(size, angle) for size in sizes for angle in angles]
    result = bytearray(struct.pack("<4sIII", b"Xcur", 16, 0x10000, len(frames)))
    offset = 16 + 12 * len(frames)
    for size, _ in frames:
        result.extend(struct.pack("<III", image_type, size, offset))
        offset += 36 + 4 * size * size
    for size, angle in frames:
        x, y = (round(point * size / 32) for point in hot)
        result.extend(struct.pack("<9I", 36, image_type, size, 1, size, size, x, y,
                                  75 if name == "wait" else 0))
        result.extend(pixels(art, size, angle))
    return result


def sound(name, segments, gain):
    samples = bytearray()
    for frequency, duration in segments:
        count = round(24000 * duration)
        for index in range(count):
            envelope = min(1, index / 90, (count - index) / 120) * (1 - index / count)
            signal = math.sin(2 * math.pi * frequency * index / 24000)
            samples.extend(struct.pack("<h", round(signal * envelope * gain)))
    with wave.open(str(SOUNDS / (name + ".wav")), "wb") as output:
        output.setparams((1, 2, 24000, 0, "NONE", "not compressed"))
        output.writeframes(samples)


def main():
    cursors = ICONS / "cursors"
    cursors.mkdir(parents=True, exist_ok=True)
    (ICONS / "index.theme").write_text("[Icon Theme]\nName=ImperialTargeting\nInherits=breeze_cursors\n")
    for name, (art, hot, aliases) in CURSORS.items():
        (cursors / name).write_bytes(cursor(name, art, hot))
        for alias in aliases:
            link = cursors / alias
            link.unlink(missing_ok=True)
            link.symlink_to(name)
    SOUNDS.mkdir(parents=True, exist_ok=True)
    sound("priority", [(760, .11), (1060, .12)], 2800)
    sound("workspace", [(245, .055), (420, .035)], 1700)


if __name__ == "__main__":
    main()
