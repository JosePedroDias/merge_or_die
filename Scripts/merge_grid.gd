extends TileMap

class_name MergeGrid

@export_category("dimensions")
@export_range(1, 40) var columns = 12
@export_range(1, 40) var rows    = 12

@export_category("props")
@export_range(1, 4) var level = 1

@export_category("audios")
@export var fillAudio: Node
@export var incomingTickAudio: Node
@export var mergeAudio: Node
@export var mistakeAudio: Node
@export var penaltyAudio: Node

var rng = RandomNumberGenerator.new()

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

var levels = {
	1: {
		"size": [5, 5],
		"penalty_countdown": 75.0,
		"fill_countdown": 2.0,
		"goal_number": 5,
	},
	2: {
		"size": [7, 7],
		"penalty_countdown": 60.0,
		"fill_countdown": 2.0,
		"goal_number": 6,
	},
	3: {
		"size": [8, 8],
		"penalty_countdown": 45.0,
		"fill_countdown": 2.0,
		"goal_number": 7,
	},
	4: {
		"size": [9, 9],
		"penalty_countdown": 30.0,
		"fill_countdown": 1.5,
		"goal_number": 8,
	},
}

var lvl = levels[level]

var bar_left = lvl["penalty_countdown"]
var fill_left = lvl["fill_countdown"]

func _ready():
	clear_layer(DEFAULT_LAYER)
	
	for y in rows:
		for x in columns:
			var coords = Vector2i(
				int(x - columns/2.0),
				int(y - rows   /2.0)
			)
			set_tile_cell(coords, 1) #??
	
func _process(delta):
	if bar_left - delta <= 0:
		clear_cells()
		bar_left = lvl["penalty_countdown"]
		penaltyAudio.play()
	else:
		bar_left -= delta
		
	if fill_left - delta <= 0:
		fill_empty_cell()
		fill_left = lvl["fill_countdown"]
		fillAudio.play()
	else:
		fill_left -= delta

func set_tile_cell(coords: Vector2i, num: int):
	var num_s = "%s" % num
	set_cell(DEFAULT_LAYER, coords, TILE_SET_ID, CELLS[num_s])
	var td = get_cell_tile_data(DEFAULT_LAYER, coords, TILE_SET_ID)
	td.set_custom_data('num', num)

func get_tile_num(coord: Vector2i):
	var td = get_cell_tile_data(DEFAULT_LAYER, coord, TILE_SET_ID)
	if td:
		return td.get_custom_data('num')
	return null

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
	
		var v = get_tile_num(coord)
		var v0 = get_tile_num(coord0)

		if v == v0:
			erase_cell(DEFAULT_LAYER, coord0)
			v += 1
			set_tile_cell(coord, v)
			mergeAudio.play()
		else:
			mistakeAudio.play()
			bar_left -= 1.0

func clear_cells():
	var positions = get_board_positions()
	for p in positions:
		if get_tile_num(p) == null:
			continue
		var r = rng.randf_range(0.0, 1.0)
		if r < 0.25:
			erase_cell(DEFAULT_LAYER, p)
	
func fill_empty_cell():
	var positions = get_board_positions()
	var p = positions[ rng.randi_range(0, positions.size()-1) ]
	set_tile_cell(p, 1)

func get_board_positions() -> Array:
	var arr: Array = []
	for y in rows:
		for x in columns:
			arr.push_back(Vector2i(
				int(x - columns/2.0),
				int(y - rows   /2.0)
			))
	return arr

func get_matching_positions(arr: Array, fn) -> Array:
	var arr2: Array = []
	for p in arr:
		if fn.call(p):
			arr2.push_back(p)
	return arr2
