extends Node

var in_game = false

func _ready() -> void:
	var args = OS.get_cmdline_args() 
	print("Command line arguments: ", args)
	if '--server' in args: 
		print("**server mode**")
		_on_room_pressed()
	
	Signals.game_over.connect(_game_over)

func _game_over():
	await get_tree().create_timer(2.0).timeout
	var nodes = get_children()
	
	for i in nodes:
		i.modulate.a = 0
		i.show()
	
	for j in range(50):
		for i in nodes:
			i.modulate.a += 0.02
			await get_tree().create_timer(0).timeout
	
	
func _on_start_pressed():
	var player_name = $EnterName.text
	if $EnterName.text == "":
		player_name = "名無し"
	
	for i in get_children():
		i.hide()
		i.hide()
		
	if in_game:
		Signals.retry.emit()
	else:
		in_game = true
		$Room.queue_free()
		Scene.change_scene("res://scene/01_main/main.tscn", {"player_name": player_name, "mode": "client"}, "no effect")
	
# サーバになる
func _on_room_pressed():
	$/root/Import/UI/Title.hide()
	Scene.change_scene("res://scene/01_main/main.tscn", {"player_name": "server", "mode": "server"}, "no effect")
