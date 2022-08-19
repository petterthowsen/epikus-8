extends Control

export(bool) var testing:bool = false

onready var tilesetSelector = $VBoxContainer/Tilesets/Panel/TilesetSelector
onready var tilesetControl:TilesetControl = $VBoxContainer/Tilesets/TilesetContainer/TilesetControl
onready var canvas:Canvas = $VBoxContainer/Main/Painter/VBoxContainer/Canvas
onready var palette:PaletteSelector = $VBoxContainer/Main/PaletteSelector
onready var newTilesetPopup = $NewTilesetPopup
onready var addTilesetButton = $VBoxContainer/Tilesets/Panel/TilesetSelector/AddTilesetButton

var project:Project

func _ready():
	addTilesetButton.connect("pressed", newTilesetPopup, "popup_centered")
	newTilesetPopup.connect("request_add", self, "add_tileset")
	tilesetControl.connect("tile_selected", self, "_on_tile_selected")
	canvas.connect("image_changed", self, "_on_canvas_image_changed")
	tilesetSelector.connect("tileset_selected", self, "_show_tileset")
	
	# testing
	if testing:
		project = Project.new("dev")
		project.load_data()
		_open_project(project)


func _open_project(p:Project):
	project = p
	for tileset in project.tilesets.values():
		tilesetSelector.add_tileset_button(tileset)
		tilesetSelector.select_tileset(tileset)
		_show_tileset(tileset)

func _input(event):
	if event.is_action("save") and event.pressed:
		ES.echo("Saving project...")
		project.save_data()


func _show_tileset(tileset:Tileset):
	print("Showing tileset " + tileset.title)
	tilesetControl.set_tileset(tileset)
	canvas.set_image(tileset.image)
	tilesetControl.select_tile(0)
	canvas.set_image_region(tilesetControl.get_selected_region())

func _on_tile_selected(tile):
	canvas.set_image_region(tilesetControl.get_selected_region())
	$VBoxContainer/Main/Painter/TileID.text = "#" + str(tile)

func _on_canvas_image_changed():
	tilesetControl.update_texture()

func add_tileset(name:String, width:int, height:int, tilesize:int):
	ES.echo("adding tileset with size " + str(width) + "x" + str(height) + " and a tilesize of " + str(tilesize))
	var tileset = project.create_tileset(name, width, height, tilesize)
	tilesetSelector.add_tileset_button(tileset)
	tilesetSelector.select_tileset(tileset)
	_show_tileset(tileset)
