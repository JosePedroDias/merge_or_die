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

@export_category("UI")
@export var label: Label
@export var bar: Panel

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

func _ready() -> void:
	clear_layer(DEFAULT_LAYER)
	
	for y in rows:
		for x in columns:
			var coords = Vector2i(
				int(x - columns/2.0),
				int(y - rows   /2.0)
			)
			set_tile_cell(coords, 1) #??
	
	_update_label()
	_update_bar(1.0)
	
func _process(delta: float) -> void:
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

func set_tile_cell(coords: Vector2i, num: int) -> void:
	var num_s = "%s" % num
	set_cell(DEFAULT_LAYER, coords, TILE_SET_ID, CELLS[num_s])
	var td = get_cell_tile_data(DEFAULT_LAYER, coords, TILE_SET_ID)
	td.set_custom_data('num', num)

func get_tile_num(coord: Vector2i):
	var td = get_cell_tile_data(DEFAULT_LAYER, coord, TILE_SET_ID)
	if td:
		return td.get_custom_data('num')
	return null

func set_highlight(coords: Vector2i, state: bool) -> void:
	clear_layer(HIGHLIGHTS_LAYER)
	if state:
		set_cell(HIGHLIGHTS_LAYER, coords, TILE_SET_ID, CELLS["highlight"])
	else:
		erase_cell(HIGHLIGHTS_LAYER, coords)

func _validate_coords(coords: Vector2i) -> bool:
	var min_x = int(-columns/2.0)
	var min_y = int(-rows/2.0)
	var x = coords[0]
	var y = coords[1]
	return x >= min_x && x < min_x + columns && y >= min_y && y < min_y + rows

func _update_label():
	label.text = "level:%d  goal:%s  %ds" % [1, 2, 3]
	

# r is how full, where 0 is empty
func _update_bar(r: float) -> void:
	var w = 900 * r
	bar.set_size(Vector2(w, 50))
	var sb = bar.get_theme_stylebox("panel")
	sb.set("bg_color", Color(1.0, r, 0.0))
	bar.position.x = 0.0 - w/2.0

	#bar.material.set_
	# TODO change color and size

func _input(event: InputEvent) -> void:
	# escape exits the game
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	
	# ignore events from types other than input event
	if !(event is InputEventMouseButton) || !event.pressed: return
	
	# convert coords and make sure they're in the board
	var coord = local_to_map(get_local_mouse_position())
	var is_valid = _validate_coords(coord)
	if !is_valid: return
	
	# handle click cell logic
	if highlighted == null:
		# first pair click
		highlighted = coord
		set_highlight(coord, true)
	elif highlighted && highlighted[0] == coord[0] && highlighted[1] == coord[1]:
		# same cell
		highlighted = null
		set_highlight(coord, false)
	else:
		# regular pair
		var coord0 = highlighted
		highlighted = null
		set_highlight(coord, false)
	
		var v = get_tile_num(coord)
		var v0 = get_tile_num(coord0)

		if v == v0:
			# numbers are the same, ok
			erase_cell(DEFAULT_LAYER, coord0)
			v += 1
			set_tile_cell(coord, v)
			mergeAudio.play()
			_update_label()
			_update_bar(rng.randf())
		else:
			# numbers differ, penalize player!
			mistakeAudio.play()
			bar_left -= 1.0

func clear_cells() -> void:
	var positions = get_board_positions()
	for p in positions:
		if get_tile_num(p) == null:
			continue
		var r = rng.randf_range(0.0, 1.0)
		if r < 0.25:
			erase_cell(DEFAULT_LAYER, p)
	
func fill_empty_cell() -> void:
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
