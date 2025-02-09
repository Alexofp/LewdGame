extends ColorRect

var colour = Color.gray
var radius = 10.0
var offset = 90.0
var size = 45
var number = 0
var blind = false  

func _ready() -> void:
	number = RNG.randi_range(1, 6)

func _draw():
	match number:
		1:
			draw_circle(Vector2(offset + 0, offset + 0), radius, pickColor())
		2:
			draw_circle(Vector2(offset + size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + size), radius, pickColor())
		3:
			draw_circle(Vector2(offset + 0, offset + 0), radius, pickColor())
			draw_circle(Vector2(offset + size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + size), radius, pickColor())
		4:
			draw_circle(Vector2(offset - size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset + size), radius, pickColor())
		5:
			draw_circle(Vector2(offset + 0, offset + 0), radius, pickColor())
			draw_circle(Vector2(offset - size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset + size), radius, pickColor())
		6:
			draw_circle(Vector2(offset + size, offset - 0), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + 0), radius, pickColor())
			draw_circle(Vector2(offset - size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset - size, offset + size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset - size), radius, pickColor())
			draw_circle(Vector2(offset + size, offset + size), radius, pickColor())
		_:
			draw_circle(Vector2(offset + 0, offset + 0), 0, pickColor())

func pickColor():
	if blind && RNG.chance(10):
		return color
	return colour
