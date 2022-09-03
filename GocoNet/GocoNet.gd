class_name GocoNet extends HTTPRequest

signal info_received(info)
signal games_received(games)
signal bad_response(result, response_code, headers, body)

const ADDRESS := "https://goco8.local/api"
const VERIFY_SSL := false

func _ready():
	pass

func _disconnect_all():
	if is_connected("request_completed", self, "info_received"):
		disconnect("request_completed", self, "info_received")
	
	if is_connected("request_completed", self, "games_received"):
		disconnect("request_completed", self, "games_received")
	

func get_info():
	_disconnect_all()
	connect("request_completed", self, "info_received")
	request(ADDRESS + "/games", PoolStringArray(), VERIFY_SSL)


func info_received(result, response_code, headers, body):
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		
		if data.error == OK:
			emit_signal("info_received", data.result)
			return
	
	emit_signal("bad_response", result, response_code, headers, body)


func get_games(page:int):
	_disconnect_all()
	connect("request_completed", self, "games_received")
	request(ADDRESS + "/games/" + str(page), PoolStringArray(), VERIFY_SSL)


func games_received(result, response_code, headers, body):
	if response_code == 200:
		var text = body.get_string_from_utf8()
		var data = JSON.parse(text)
		if data.error == OK:
			emit_signal("games_received", data.result)
			return
	
	emit_signal("bad_response", result, response_code, headers, body)


func download_game(url:String):
	_disconnect_all()
	connect("request_completed", self, "_game_downloaded")
	request(url, PoolStringArray(), VERIFY_SSL)


func _game_downloaded(result, response_code, headers, body):
	if response_code == 200:
		var f = File.new()
		f.open()
	
	emit_signal("bad_response", result, response_code, headers, body)
