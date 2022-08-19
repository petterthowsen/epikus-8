class_name Canvas extends Control

signal position_changed(position)
signal mouse_position_changed(mouse_position)
signal zoom_changed(zoom)
signal image_changed()
signal pencil_color_picked(color)

export(Texture) var test_image

var selected_color:Color = Color.white
var selected_tool:String = "pencil"

var image:Image
var image_region:Rect2
var image_texture:ImageTexture

var zoom:int = 1
var zoom_max:int = 40
var camera := Vector2(0, 0)

var mouse_position := Vector2()
var mouse_pixel_position := Vector2()

var pencil_is_drawing:bool = false

func _ready():
	if test_image:
		set_image(test_image.get_data())
	
	#connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_exited():
	pencil_is_drawing = false


func set_selected_color(color:Color):
	selected_color = color


func set_image(img:Image):
	image = img
	
	image_texture = ImageTexture.new()
	image_texture.create_from_image(image, 0)
	
	image.lock()
	
	zoom = 1
	var size = get_rect().size
	
	# center camera
	camera = Vector2(size.x / 2, size.y / 2)
	
	# zoom to fit
	zoom_to_fit()
	zoom_max = 10


func set_image_region(region:Rect2):
	image_region = region
	update()


func update_image_texture():
	image_texture.set_data(image)


func set_zoom(z:int):
	zoom = clamp(z, 1, zoom_max)

func get_zoom() -> int:
	return zoom

func zoom_to_fit():
	var size = get_rect().size
	var img_size = image.get_size()
	
	if image_region:
		img_size = image_region.size
	
	var x = size.x / img_size.x
	var y = size.y / img_size.y
	
	if x < y:
		zoom = floor(x)
	else:
		zoom = floor(y)
	
	emit_signal("zoom_changed", zoom)

func set_mouse_position(pos:Vector2):
	mouse_position = pos
	mouse_pixel_position = mouse_to_pixel(mouse_position)
	emit_signal("mouse_position_changed", mouse_position)
	
func mouse_pixel_position_in_bounds() -> bool:
	var img_size = image.get_size()
	if image_region:
		img_size = image_region.size
	
	if mouse_pixel_position.x < 0:
		return false
	if mouse_pixel_position.y < 0:
		return false
	if mouse_pixel_position.x >= img_size.x:
		return false
	if mouse_pixel_position.y >= img_size.y:
		return false
	
	return true

func _gui_input(event):
	if not image:
		return
	
	if event is InputEventMouse:
		if event.position != mouse_position:
			mouse_position = event.position
			set_mouse_position(mouse_position)
		
		if event is InputEventMouseButton:
			if event.is_action("zoom_in") and event.pressed:
				set_zoom(zoom+1)
				update()
			elif event.is_action("zoom_out") and event.pressed:
				set_zoom(zoom-1)
				update()
			else:
				apply_tool(event)
		elif event is InputEventMouseMotion:
			apply_tool(event)


func set_pixel(pixel:Vector2, color: Color):
	if image_region:
		pixel += image_region.position
	
	image.set_pixelv(pixel, color)
	emit_signal("image_changed")


func get_pixel(pixel: Vector2) -> Color:
	if image_region:
		pixel += image_region.position
	return image.get_pixelv(pixel)


func apply_tool(event:InputEventMouse):
	var pixel = mouse_pixel_position
	
	if selected_tool == "pencil":
		if pencil_is_drawing and event is InputEventMouseMotion:
			if mouse_pixel_position_in_bounds():
				set_pixel(pixel, selected_color)
				update_image_texture()
				update()
		elif event.is_action("left_click"):
			if event.pressed:
				pencil_is_drawing = true
				if mouse_pixel_position_in_bounds():
					set_pixel(pixel, selected_color)
					update_image_texture()
					update()
			else:
				pencil_is_drawing = false
		elif event.is_action("right_click"):
			selected_color = image.get_pixelv(pixel)
			emit_signal("pencil_color_picked", selected_color)


func mouse_to_pixel(mouse:Vector2) -> Vector2:
	if image:
		
		var size = get_rect().size
		var center = size / 2
		
		var img_size = image.get_size()
		if image_region:
			img_size = image_region.size
		
		var pixel = mouse
		pixel -= center
		pixel /= zoom
		pixel += img_size / 2
		
		#pixel += img_size / 2
		
		return pixel.floor()
	return Vector2()


func _draw():
	# draw background
	var size = get_rect().size
	var center = size / 2
	
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.1, 0.1, 0.1), true, 1.0, false)
	
	# draw image
	if image:
		var img_size = image.get_size()
		if image_region:
			img_size = image_region.size
		var pos = center - ((img_size / 2) * zoom)
		pos = pos.floor()
		
		draw_rect(Rect2(pos, img_size * zoom), Color.black, true)
		
		if image_region:
			draw_texture_rect_region(image_texture, Rect2(pos, img_size * zoom), image_region)
		else:
			draw_texture_rect(image_texture, Rect2(pos, img_size * zoom), false)
			
		
