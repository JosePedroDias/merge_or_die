extends TileMap

class_name MergeGrid

@export_category("dimensions")
@export_range(1, 40) var columns = 12
@export_range(1, 40) var rows    = 12

@export_category("audios")
@export var fillAudio: Node
@export var incomingTickAudio: Node
@export var mergeAudio: Node
@export var mistakeAudio: Node
@export var penaltyAudio: Node

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
			
	var timer := Timer.new()
	#timer.wait_time = 2 # default is 1 sec
	add_child(timer)
	timer.connect("timeout", _every_sec)
	timer.start()

func _every_sec() -> void:
	fillAudio.play() # TODO to use when numbers are added back
	#incomingTickAudio.play() # TODO to use when bar is about to exhaust (seconds 4 to 1)
	#mergeAudio.play()
	#mistakeAudio.play()
	#penaltyAudio.play() # TODO to use when bar is exhausted
	
			
func set_tile_cell(coords: Vector2i, num: int):
	var num_s = "%s" % num
	set_cell(DEFAULT_LAYER, coords, TILE_SET_ID, CELLS[num_s])
	var td = get_cell_tile_data(DEFAULT_LAYER, coords, TILE_SET_ID)
	td.set_custom_data('num', num)
	
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
	
		var td = get_cell_tile_data(DEFAULT_LAYER, coord, TILE_SET_ID)
		var td0 = get_cell_tile_data(DEFAULT_LAYER, coord0, TILE_SET_ID)
		
		if td != null && td0 != null:
			var v  = td.get_custom_data('num')
			var v0 = td0.get_custom_data('num')

			if v == v0:
				erase_cell(DEFAULT_LAYER, coord0)
				v += 1
				set_cell(	DEFAULT_LAYER, coord, TILE_SET_ID, CELLS["%s" % v])
				var td2 = get_cell_tile_data(DEFAULT_LAYER, coord, TILE_SET_ID)
				td2.set_custom_data('num', v)
				mergeAudio.play()
			else:
				mistakeAudio.play()
				# TODO: decrease bar
			
