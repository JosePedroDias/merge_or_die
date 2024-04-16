extends TileMap

class_name MergeGrid

@export var columns = 12
@export var rows    = 12

var highlighted = Vector2i(0, 0)

const TILE_SET_ID = 0
const DEFAULT_LAYER = 0
const HIGHLIGHTS_LAYER = 1

const CELLS = {
	"1": Vector2i(0, 0),
	"2": Vector2i(1, 0),
	"3": Vector2i(2, 0),
	"4": Vector2i(0, 1),
	"5": Vector2i(1, 1),
	"6": Vector2i(2, 1),
	"7": Vector2i(0, 2),
	"8": Vector2i(1, 2),
	"highlight": Vector2i(2, 2),
}

func _ready():
	clear_layer(DEFAULT_LAYER)
	
	for y in rows:
		for x in columns:
#warning-ignore:integer_division
			var coords = Vector2i(x - columns / 2, y - rows / 2)
			set_tile_cell(coords, "1")
			pass
			
	set_highlight(Vector2i(0, 0))
			
func set_tile_cell(coords: Vector2i, cell_type: String):
	set_cell(DEFAULT_LAYER, coords, TILE_SET_ID, CELLS[cell_type])
	
func set_highlight(coords: Vector2i):
	highlighted = coords
	clear_layer(HIGHLIGHTS_LAYER)
	set_cell(HIGHLIGHTS_LAYER, coords, TILE_SET_ID, CELLS["highlight"])

func _input(event: InputEvent):
	if !(event is InputEventMouseButton) || !event.pressed:
		print(event)
