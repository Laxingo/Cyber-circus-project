extends Node2D

const SlotTile := preload("res://scenes/Tile.tscn")
const SPIN_UP_DISTANCE = 100.0
signal stopped


export(Array, String) var pictures := [
  preload("res://Imagens/Simbolos/CyberCircus_Bunny.png"),
  preload("res://Imagens/Simbolos/CyberCircus_Clown.png"),
  preload("res://Imagens/Simbolos/CyberCircus_Elephant.png"),
  preload("res://Imagens/Simbolos/CyberCircus_J.001_cropped.png"),
  preload("res://Imagens/Simbolos/CyberCircus_K.001_cropped.png"),
  preload("res://Imagens/Simbolos/CyberCircus_Lion.png"),
  preload("res://Imagens/Simbolos/CyberCircus_Malabare.png"),
  preload("res://Imagens/Simbolos/CyberCircus_MuscleMan.png"),
  preload("res://Imagens/Simbolos/CyberCircus_Q.001_cropped.png"), 
]

export(int,1,20) var reels := 5
export(int,1,20) var tiles_per_reel :=3 
export(float,0,10) var runtime := 1.7
export(float,0.1,10) var speed := 5.0
export(float,0,2) var reel_delay := 0.2

onready var size := get_viewport_rect().size
onready var tile_size := size / Vector2(reels, tiles_per_reel)
onready var speed_norm := speed * tiles_per_reel
onready var extra_tiles := int(ceil(SPIN_UP_DISTANCE / tile_size.y) * 2)

onready var rows := tiles_per_reel + extra_tiles
onready var cells = rows * reels

onready var random = RandomNumberGenerator.new()

var tileTex
var result_texture

enum State {OFF, ON, STOPPED}
var state = State.OFF
var result := {}
var tile_name

const tiles := []
const grid_pos := []

onready var expected_runs :int = int(runtime * speed_norm)
var tiles_moved_per_reel := []
var runs_stopped := 0
var total_runs : int


var col1Mid
var col2Mid 
var col3Mid 
var col4Mid 
var col5Mid 

var col1Mid_name
var col2Mid_name
var col3Mid_name
var col4Mid_name
var col5Mid_name

var names=["bunny", "clown", "elephant", "J", "K", "Lion", 
"Malabare", "Strongman", "Q"]

var bunny = 0
var clown= 0
var elephant= 0
var j= 0
var k= 0
var lion= 0
var malabare= 0
var strongman= 0
var q= 0

var masks=[bunny, clown, elephant, j, k, lion,
malabare, strongman, q]
var reel1


var prizeNmr = 3
var prizeMask = []


func _ready():
	prizeMask.push_back(0b000000000011111)
	prizeMask.push_back(0b000001111100000)
	prizeMask.push_back(0b111110000000000)


#	prizeMask[0] = 0b111110000000000;
#	prizeMask[1] = 0b000001111100000;
#	prizeMask[2] = 0b000000000011111;


#	reel1 = 1 << 0
#	reel1|= 1 << 2
#	reel1|= 1 << 1
#	reel1|= 1 << 3
#	reel1|= 1 << 4
#	print(reel1)
#	masks[3] = 1<< 3
#	print(masks[2])
	
	for col in reels:
		grid_pos.append([])
		tiles_moved_per_reel.append(0)
		for row in range(rows): 
			grid_pos[col].append(Vector2(col, row - 0.9 *extra_tiles) * tile_size) 
			_add_tile(col, row)
	
	teste()
  
func _add_tile(col :int, row :int) -> void:
	tiles.append(SlotTile.instance())
	var tile := get_tile(col, row) 
	tile.get_node('Tween').connect("tween_completed", self, "_on_tile_moved")
	tile.set_texture(_randomTexture())
	tile.set_size(tile_size)
	tile.set_name(tile_name)
	tile.position = grid_pos[col][row]
	tile.set_speed(speed_norm)
	add_child(tile)

func get_tile(col :int, row :int) -> SlotTile:
  return tiles[(col * rows) + row]


func start() -> void:
 if state == State.OFF: 
		state = State.ON 
		total_runs = expected_runs
		_get_result()
		print(result)
	for reel in reels:
		_spin_reel(reel)
		if reel_delay > 0:
			   yield(get_tree().create_timer(reel_delay), "timeout")
  
func stop():
	state = State.STOPPED
	runs_stopped = current_runs()
	total_runs = runs_stopped + tiles_per_reel + 1
	

func _stop() -> void:
	for reel in reels:
		tiles_moved_per_reel[reel] = 0
		state = State.OFF
		emit_signal("stopped")
	
	if state == State.OFF:
		idk()
#		checkMidReel()



func _spin_reel(reel :int) -> void:
  for row in rows:
   _move_tile(get_tile(reel, row))

func _move_tile(tile :SlotTile) -> void:
  tile.spin_up()
  yield(tile.get_node("Animations"), "animation_finished")
  tile.move_by(Vector2(0, tile_size.y))
  
func _on_tile_moved(tile: SlotTile, _nodePath) -> void:
	var reel := int(tile.position.x / tile_size.x)
	tiles_moved_per_reel[reel] += 1
	var reel_runs := current_runs(reel)
	if (tile.position.y > grid_pos[0][-1].y):
		tile.position.y = grid_pos[0][0].y
	var current_idx = total_runs - reel_runs
	if (current_idx < tiles_per_reel):
		var result_texture = pictures[result.tiles[reel][current_idx]] 
		var randomtex = _randomTexture()
		tile.set_texture(randomtex)
		tile.set_name(tile_name)
	else:
		var randomtex = _randomTexture()
		tile.set_texture(randomtex)
		tile.set_name(tile_name)
	if (state != State.OFF && reel_runs != total_runs):
		tile.move_by(Vector2(0, tile_size.y))
	else: 
		tile.spin_down()
#		print(str(reel) + " - " + str(reels))
		if reel == reels - 1:
			_stop()

func idk():
	col1Mid = get_tile(0,3)
	col2Mid = get_tile(1,3)
	col3Mid = get_tile(2,3)
	col4Mid = get_tile(3,3)
	col5Mid = get_tile(4,3)
	
	col1Mid_name = col1Mid.tileName
	col2Mid_name = col2Mid.tileName
	col3Mid_name = col3Mid.tileName
	col4Mid_name = col4Mid.tileName
	col5Mid_name = col5Mid.tileName

	print(col1Mid_name)
	print(col2Mid_name)
	print(col3Mid_name)
	print(col4Mid_name)
	print(col5Mid_name)

func current_runs(reel := 0) -> int:
  return int(ceil(float(tiles_moved_per_reel[reel]) / rows))

func _randomTexture() -> String:
	random.randomize()
	var num = random.randi_range(0, 8)
	if num == 0:
		tile_name = names[0]
	elif num == 1:
		tile_name = names[1]
	elif num == 2:
		tile_name = names[2]
	elif num == 3:
		tile_name = names[3]
	elif num == 4:
		tile_name = names[4]
	elif num == 5:
		tile_name = names[5]
	elif num == 6:
		tile_name = names[6]
	elif num == 7:
		tile_name = names[7]
	elif num == 8:
		tile_name = names[8] 
	return pictures[num  %pictures.size()]

func _get_result() -> void:
  result = {
	"tiles": [
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ],
	  [ 0,0,0,0 ]
	]}
	

#func checkMidReel():
#	if col1Mid_name == col2Mid_name:
#		if col2Mid_name == col3Mid_name:
#			if col3Mid_name == col4Mid_name:
#				if col4Mid_name == col5Mid_name:
#					print("5 Iguais na reel do meio")
#				else:
#					print("4 Iguais na reel do meio")
#			else:
#				print("3 Iguais na reel do meio")
#		else:
#			print("2 Iguais na reel do meio")
#	else:
#		print("Nenhuma Igual na reel do meio")

func teste():
#	if col1Mid_name == "leao":
#		reel1 = 1<<0
#	if col2Mid_name == "leao":
#		reel1 |= 1<<1
#	if col3Mid_name == "leao":
#		reel1 |= 1<<2
#	if col4Mid_name == "leao":
#		reel1 |= 1<<3
#	if col5Mid_name == "leao":
#		reel1 |= 1<<4
		
	for n in masks.size():
		
		for l in range(2, 5):
			for r in range(0, 5):
			
				#print("XXX: ", ceil(r/5))
				var tile = get_tile(l , r)
				var tilename = tile.tileName
				#if tilename == names[n]:
					#masks[n] |= 1 << r
				print("L: ", l, "R: ", r)
	for o in prizeMask.size():
		for q in masks.size():
			if(prizeMask[o] & masks[q] == masks[q]):
				print(prizeMask)
				print(masks)
				print("O:::: ",o); 
		
		
#		if masks[n] == 31:
#			print("Parabens: 5 " + names[n] + " seguidos")
#		elif masks[n] == 30 || masks[n] == 15:
#			print("Parabens: 4 " + names[n] + " seguidos")
#		elif masks[n] == 7 || masks[n] == 14 || masks[n] == 28:
#			print("Parabens: 3 " + names[n] + " seguidos")
#		elif masks[n] == 3 || masks[n] == 6 || masks[n] == 12 || masks[n] == 24:
#			print("Parabens: 2 " + names[n] + " seguidos")
