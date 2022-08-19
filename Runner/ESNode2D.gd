class_name ESNode2D extends Node2D

var _project:Project
onready var _camera = $"/root/Runner/Camera"

func _start():
	pass

# get camera
func get_camera():
	return _camera


# get tileset
func get_tileset(tileset_name:String) -> Tileset:
	return _project.tilesets[tileset_name]

# get map
func get_map(map_name:String) -> Map:
	return _project.maps[map_name]


func draw_map(map_name:String, pos_x:int, pos_y:int):
	var map = get_map(map_name)
	for layer in map.layers:
		for x in map.size.x:
			for y in map.size.y:
				var tile = layer.get_tile_g(x, y)
				if not tile.is_empty():
					var rect = Rect2(pos_x + (x * layer.tile_size), pos_y + (y * layer.tile_size), layer.tile_size, layer.tile_size)
					var src_rect = tile.region
					draw_texture_rect_region(tile.tileset.texture, rect, src_rect)


# draw a single sprite tile
func draw_sprite(tileset_name:String, tile_index:int, x:int, y:int, w:int = -1, h:int = -1):
	var tileset:Tileset = _project.tilesets[tileset_name]
	
	if w == -1:
		w = tileset.tile_size
	
	if h == -1:
		h = tileset.tile_size
	
	var rect = Rect2(x, y, w, h)
	
	var src_rect = tileset.get_region(tile_index)
	
	draw_texture_rect_region(tileset.texture, rect, src_rect)
