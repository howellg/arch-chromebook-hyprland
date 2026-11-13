"""Build the Galactic Waybar symbols with FontTools."""
from pathlib import Path
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

# Each closed polygon is specified on a 24-unit grid, with y pointing down.
SYMBOLS = {
    "tie": [[(2,3),(5,5),(5,10),(9,10),(10,7),(14,7),(15,10),(19,10),(19,5),(22,3),(22,21),(19,19),(19,14),(15,14),(14,17),(10,17),(9,14),(5,14),(5,19),(2,21)]],
    "destroyer": [[(12,2),(23,21),(12,17),(1,21)],[(12,8),(8,17),(12,15),(16,17)]],
    "holocron": [[(12,1),(23,16),(12,23),(1,16)],[(12,5),(5,15),(11,18),(11,8)],[(13,8),(13,18),(19,15),(13,5)]],
    "rakatan": [[(12,1),(23,12),(12,23),(1,12)],[(12,5),(5,12),(12,19),(19,12)],[(12,8),(16,12),(12,16),(8,12)]],
    "dish": [[(4,4),(17,14),(16,17),(10,18),(5,15),(3,10)],[(13,9),(18,4),(20,6),(15,11)],[(10,18),(13,18),(13,21),(18,21),(18,23),(6,23),(6,21),(10,21)]],
    "datacard": [[(5,2),(16,2),(21,7),(21,22),(3,22),(3,4)],[(7,6),(7,9),(16,9),(16,6)],[(7,13),(7,16),(17,16),(17,13)]],
    "station": [[(8,2),(16,2),(21,6),(23,11),(22,16),(17,22),(7,22),(2,17),(1,11),(3,6)],[(4,11),(4,13),(20,13),(20,11)],[(13,4),(11,5),(10,7),(11,9),(14,10),(16,8),(16,5)]],
}

def main():
    font = FontBuilder(1024, isTTF=True)
    order = [".notdef", *SYMBOLS]
    font.setupGlyphOrder(order)
    font.setupCharacterMap({0xE900 + i: name for i, name in enumerate(SYMBOLS)})
    glyphs = {".notdef": TTGlyphPen(None).glyph()}
    for name, contours in SYMBOLS.items():
        pen = TTGlyphPen(None)
        for contour in contours:
            points = [(x * 38, (20 - y) * 38) for x, y in contour]
            pen.moveTo(points[0])
            for point in points[1:]:
                pen.lineTo(point)
            pen.closePath()
        glyphs[name] = pen.glyph()
    font.setupGlyf(glyphs)
    font.setupHorizontalMetrics({name: (912, font.font["glyf"][name].xMin if name in SYMBOLS else 0) for name in order})
    font.setupHorizontalHeader(ascent=800, descent=-200)
    font.setupNameTable({"familyName": "Galactic Sector", "styleName": "Regular",
                         "fullName": "Galactic Sector", "psName": "GalacticSector-Regular"})
    font.setupOS2(sTypoAscender=800, sTypoDescender=-200, usWinAscent=800, usWinDescent=200)
    font.setupPost()
    font.save(Path(__file__).with_name("GalacticSector.ttf"))

if __name__ == "__main__":
    main()
