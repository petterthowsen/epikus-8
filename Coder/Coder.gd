class_name Coder extends Control

const Editor = preload("res://Coder/Editor.tscn")

var has_focus:bool = false

var project:Project

var code_template = """extends ESNode2D

func _ready():
	pass

func _process(delta):
	pass

func _draw():
	pass
"""

func _ready():
	$Sidebar/Tree.connect("request_open", self, "_on_request_open")


func _open_project(project:Project):
	self.project = project
	$Sidebar/Tree.project = project
	$Sidebar/Tree.set_folder(project.get_code_dir())


func _close_project():
	project = null
	$Sidebar/Tree.project = null
	$Sidebar/Tree.clear()


func _save_project(project:Project):
	for editor in $EditorTabs.get_children():
		if editor.dirty:
			editor.save()


func grab_focus():
	has_focus = true
	$EditorTabs.grab_focus()
	$EditorTabs.grab_click_focus()


func release_focus():
	has_focus = false


func _input(event:InputEvent):
	if event.is_action("ctrl_tab") and event.pressed:
		if $Sidebar.is_visible:
			$Sidebar.hide()
			$EditorTabs.grab_focus()
			$EditorTabs.grab_click_focus()
		else:
			$Sidebar.show()
			$Sidebar.grab_focus()
			$Sidebar.grab_click_focus()
		get_tree().set_input_as_handled()


func is_file_open(path:String):
	for editor in $EditorTabs.get_children():
		if editor.file == path:
			return true
	return false


func _on_request_open(path:String):
	if not is_file_open(path):
		open_file(path)


func open_file(path:String):
	var f = File.new()
	
	var err = f.open(path, File.READ)
	if err:
		ES.echo("Editor failed to open file at " + path + ". Err:" + str(err))
		return false
		
	var text = f.get_as_text()
	f.close()
	
	var tab = Editor.instance()
	tab.file = path
	tab.text = text
	
	var tab_name = Array(path.split("/")).pop_back()
	
	$EditorTabs.add_child(tab)
	$EditorTabs.set_tab_title(tab.get_index(), tab_name)
	$EditorTabs.current_tab = tab.get_index()
	$EditorTabs.tabs_visible = true


func _on_AddScriptButton_pressed():
	var item:Node = $Sidebar/Tree.new_file()
	item.connect("file_renamed", self, "_on_new_file_named", [item])


func _on_new_file_named(old_path, new_path, item):
	if not new_path.ends_with(".gd"):
		new_path = new_path + ".gd"
	
	var f = File.new()
	var err = f.open(new_path, File.WRITE)
	if err:
		ES.echo("Failed to open " + new_path + " for writing new code file. Err: " + str(err))
	else:
		f.store_line(code_template)
		f.close()
	
	item.disconnect("file_renamed", self, "_on_new_file_named")
	
	if not err:
		item.path = new_path
		open_file(new_path)
