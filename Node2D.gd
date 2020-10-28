#tool 
extends Node2D

var last_modified_time := 0
var led := {}
var root_node



func _ready():
	
	# make a new node to work in
	root_node = Node2D.new()
	add_child(root_node)
	
	# get all data from led json file
	led = get_led_data("res://myled.json")

	
	# create all tilesets
#	create_tilesets(led.defs.tilesets)

	# draw all layers of a level and save the level	
	draw_all_layers(0, led)
	



# get layer by its id and give the layer's data (where we can find the tileset id. could be great if we can get it from the level.layer)
func get_layer_by_id (id:int, layers:Array) -> Dictionary:
	
	for l in layers:
		if l.uid == id:
			return l
	return {}
	



# draw all layers of a specific level and save it in a file
func draw_all_layers(level_id:int, led_data:Dictionary):
	
	var layers : Array = led_data.levels[level_id].layerInstances
	layers.invert()
	
	for layer in layers :
		var tile_map = draw_layer(layer, led_data)
		tile_map.owner = root_node
				
	var packed_scene = PackedScene.new()

	root_node.set_name(str("Level", level_id))
	packed_scene.pack(root_node)
	ResourceSaver.save(str("res://Level", level_id, ".tscn"), packed_scene)
	



# draw a layer of a level
func draw_layer(layer:Dictionary, led_data:Dictionary):
	
	var current_layer = get_layer_by_id(layer.layerDefUid, led_data.defs.layers)	
	
	var tileset : TileSet = load("res://LED_tileset.tres")
	
	var gridSize = layer.__gridSize
	
	# create a tilemap for this layer
	var tile_map := TileMap.new()
	tile_map.set_tileset(tileset)
	tile_map.set_cell_size(Vector2(gridSize, gridSize))
	tile_map.name = layer.__identifier

	# add cells
	for cell in layer.gridTiles:
		tile_map.set_cell(
			cell.px[0]/gridSize, cell.px[1]/gridSize, 
			current_layer.tilesetDefUid, 
			false, false, false, 
			Vector2(cell.src[0]/gridSize, cell.src[1]/gridSize))

	root_node.add_child(tile_map)
	
	return tile_map
	

	
	
# Create a tileset file with all the tilesets inside
func create_tilesets (tilesets:Array):
	
	var tile_set = TileSet.new()
	
	for t in tilesets:
			
		var texture = load("res://" + t.relPath)
				
		tile_set.create_tile(t.uid)	# create a tile with an id
		tile_set.tile_set_tile_mode(t.uid, TileSet.ATLAS_TILE)	# tile mode
		tile_set.tile_set_name(t.uid, t.identifier)	# tile name
		tile_set.autotile_set_spacing(t.uid, t.spacing)
		tile_set.tile_set_region( t.uid, Rect2(Vector2(0,0), Vector2(t.pxWid, t.pxHei)))	# tile size
		tile_set.autotile_set_size(t.uid, Vector2(t.tileGridSize, t.tileGridSize))
		tile_set.tile_set_texture(t.uid, texture)	# tile texture
		
	ResourceSaver.save("res://LED_tileset.tres", tile_set)
	
	return tile_set
	



# get led json data
func get_led_data(file_name:String) -> Dictionary :
	
	var file = File.new()
	file.open(file_name, file.READ)
	var json_text = file.get_as_text()
	file.close()
	
	return JSON.parse(json_text).result
