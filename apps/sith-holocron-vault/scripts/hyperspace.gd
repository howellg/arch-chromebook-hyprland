extends Control

const STAR_COUNT := 84
var destination := ""
var accent := Color("#92b8e3")
var progress := 0.0
var stars: Array[Vector3] = []

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    var rng := RandomNumberGenerator.new()
    rng.seed = 74
    for i in range(STAR_COUNT):
        stars.append(Vector3(rng.randf_range(0.0, TAU), rng.randf_range(0.08, 0.87),
            rng.randf_range(0.55, 1.0)))

func advance(value: float) -> void:
    progress = value
    queue_redraw()

func _draw() -> void:
    var center := size * Vector2(0.5, 0.45)
    var radius := size.length() * 0.64
    var fade := smoothstep(0.0, 0.20, progress)
    var blackout := smoothstep(0.76, 1.0, progress)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.028, 0.063, fade))
    for star in stars:
        var direction := Vector2.from_angle(star.x)
        var stretch := progress * progress * star.z
        var head := radius * (star.y + 0.66 * stretch)
        var tail := maxf(radius * 0.045, head - radius * (0.008 + 0.31 * stretch))
        var start := center + direction * tail
        var finish := center + direction * head
        var opacity := fade * (1.0 - blackout) * star.z
        draw_line(start, finish, Color(accent, opacity * 0.32), 4.2, true)
        draw_line(start.lerp(finish, 0.24), finish,
            Color(Color("#d1e9ff").lerp(accent, 0.28), opacity * 0.88), 1.25, true)

    var font := ThemeDB.fallback_font
    var text_width := font.get_string_size(destination, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
    var banner := Rect2(Vector2((size.x - text_width) / 2 - 16, size.y * 0.82),
        Vector2(text_width + 32, 40))
    draw_rect(banner, Color(0.018, 0.028, 0.063, fade * 0.9))
    draw_line(banner.position, banner.position + Vector2(banner.size.x, 0),
        Color(accent, fade), 1.0)
    draw_string(font, banner.position + Vector2(16, 26), destination,
        HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#dde9fa", fade))
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.014, 0.020, 0.04, blackout))
