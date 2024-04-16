extends TileMap

class_name MergeGrid

@export var columns = 12
@export var rows    = 12

var highlighted = null

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
			var coords = Vector2i(
				int(x - columns/2.0),
				int(y - rows   /2.0)
			)
			set_tile_cell(coords, 1)
			
	#set_highlight(Vector2i(0, 0))
			
func set_tile_cell(coords: Vector2i, num: int):
	set_cell(DEFAULT_LAYER, coords, TILE_SET_ID, CELLS["%s" % num])
	
func set_highlight(coords: Vector2i, state: bool):
	#highlighted = coords
	clear_layer(HIGHLIGHTS_LAYER)
	if state:
		set_cell(HIGHLIGHTS_LAYER, coords, TILE_SET_ID, CELLS["highlight"])
	else:
		erase_cell(HIGHLIGHTS_LAYER, coords)

func _input(event: InputEvent):
	if !(event is InputEventMouseButton) || !event.pressed:
		return
		
	var coord = local_to_map(get_local_mouse_position())
	
	if highlighted == null:
		highlighted = coord
		set_highlight(coord, true)
	else:
		var coord0 = highlighted
		highlighted = null
		set_highlight(coord, false)
		
		var v = get_cell_source_id(DEFAULT_LAYER, coord)
		var v0 = get_cell_source_id(DEFAULT_LAYER, coord0)
		
		if v != v0:
			print("no")
		else:
			erase_cell(DEFAULT_LAYER, coord0)
			var k = v + 1
			print(k)
			set_cell(DEFAULT_LAYER, coord, TILE_SET_ID, CELLS["%s" % k])
		
		# TODO get keys for 2 positions
		# if different -> bad
		
		#if get_cell_source_id(DEFAULT_LAYER, co):
		#	pass
