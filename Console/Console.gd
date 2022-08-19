class_name Console extends PanelContainer

onready var output = $VBoxContainer/Output
onready var input = $VBoxContainer/Input

var commands := {}

var welcome_message = """
Welcome to EPIKUS!
Copyright (c) 2022 - Thowsen Media
Version: 0.1
------------------------------------
Type "help" for a list of commands.
"""

var dir:String = "user://"

func _init():
	ES.console = self

func _ready():
	add_command("help", HelpCommand.new())
	add_command("cls", ClearScreenCommand.new())
	add_command("ls", ListFilesCommand.new())
	add_command("mkdir", MakeDirCommand.new())
	add_command("cd", ChangeDirCommand.new())
	add_command("make", MakeProjectCommand.new())
	add_command("open", OpenProjectCommand.new())
	add_command("compile", CompileScriptCommand.new())
	add_command("cat", CatConsoleCommand.new())
	
	output.write(welcome_message)
	input.grab_focus()

func grab_focus():
	input.grab_focus()

func add_command(command_name: String, command:ConsoleCommand):
	commands[command_name] = command


func write(text:String):
	output.write(text)


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		output.scroll_vertical -= 1
	elif Input.is_action_pressed("ui_down"):
		output.scroll_vertical += 1
	
	if Input.is_action_just_released("ui_accept"):
		var command = input.text
		if command:
			input.text = ""
			process_command(command)

func run(command:String, args:Array):
	if commands.has(command):
		return commands[command].run(args)
	
	push_warning("Unknown command " + command)
	return null

func process_command(string:String):
	var args = Array(string.split(" "))
	var command = args.pop_front()
	
	if commands.has(command):
		var err = run(command, args)
		if err:
			output.write("[color=red]Command failed.[/color]")
	else:
		output.write("Unknown command '" + command + "'...")
