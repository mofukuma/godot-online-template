extends CanvasLayer

# クライアントになってスタート
func _on_start_pressed():
	Signals.change_scene.emit("res://scene/01_main/main.tscn", {"player_name": $entername.text, "mode": "client"}, "no effect")

# サーバになる
func _on_room_pressed():
	Signals.change_scene.emit("res://scene/01_main/main.tscn", {"player_name": "server", "mode": "server"}, "no effect")
