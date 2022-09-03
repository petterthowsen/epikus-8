class_name Runner extends Node2D

var project:Project

var log_messages := ""

func _ready():
	# load either a packed project, or a project
	if ES.scene_arguments.has("packed_project"):
		ES.echo("Running packed project...")
		
		var packed_project = ES.scene_arguments["packed_project"]
		var project := Project.new(packed_project.name)
		project.unpack(packed_project)
		
		for clazz in project.scripts.values():
			var instance = clazz.new()
			instance.add_to_group("script")
			instance._project = project
			add_child(instance)
		
	elif ES.scene_arguments.has("project"):
		ES.echo("Running project...")
		
		var project_name = ES.scene_arguments["project"]
		project = Project.new(project_name)
		project.load_data()
		var scripts = project.get_scripts()
		for script in scripts:
			var clazz = ResourceLoader.load(project.get_code_dir() + "/" + script, "", false)
			var instance = clazz.new()
			instance.add_to_group("script")
			instance._project = project
			add_child(instance)
	
	# start all scripts
	for child in get_children():
		if child.is_in_group("script") and child.has_method("_start"):
			child._start()


func echo(what:String):
	print(what)
	log_messages += what + "\n"


func _process(delta):
	for child in get_children():
		if child.is_in_group("script") and child.has_method("_draw"):
			child.update()


func _input(event):
	if event.is_action("escape") and event.pressed:
		$CanvasLayer/EscapeMenu.show()
		$CanvasLayer/EscapeMenu.grab_focus()


func quit():
	var args = {
		"launched_by_runner": true,
		"console_out": log_messages
	}
	
	if ES.scene_arguments.has("launched_by_editor"):
		if ES.scene_arguments["launched_by_editor"] == true:
			args["open"] = project.name
	ES.goto_scene("res://Editor.tscn", args)
