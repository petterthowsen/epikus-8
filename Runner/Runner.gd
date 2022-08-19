class_name Runner extends Node2D

var project:Project

func _ready():
	if ES.scene_arguments.has("project"):
		var project_name = ES.scene_arguments["project"]
		project = Project.new(project_name)
		project.load_data()
		var scripts = project.get_scripts()
		for script in scripts:
			var instance = ESNode2D.new()
			instance.set_script(load(project.get_code_dir() + "/" + script))
			instance.add_to_group("escript")
			instance._project = project
			add_child(instance)
		
		for child in get_children():
			if child.is_in_group("escript"):
				child._start()


func _input(event):
	if event.is_action("escape") and event.pressed:
		$CanvasLayer/EscapeMenu.show()
		$CanvasLayer/EscapeMenu.grab_focus()


func quit():
	ES.goto_scene("res://Editor.tscn")
