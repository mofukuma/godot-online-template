extends CanvasLayer

func _ready() -> void:
	var args = OS.get_cmdline_args() 
	print("Command line arguments: ", args)
	if '--server' in args: 
		print("server mode")
		_on_room_pressed()
	

# クライアントになってスタート
func _on_start_pressed():
	Signals.change_scene.emit("res://scene/01_main/main.tscn", {"player_name": $entername.text, "mode": "client"}, "no effect")

# サーバになる
func _on_room_pressed():
	Signals.change_scene.emit("res://scene/01_main/main.tscn", {"player_name": "server", "mode": "server"}, "no effect")
