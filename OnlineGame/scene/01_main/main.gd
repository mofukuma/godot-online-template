extends Node

# import
@onready var Scene : Scene = $/root/Global/Scene
@onready var Net : Net = $/root/Global/Net

var player_name = ""
var player_pr = preload("res://actor/player/multiplayer_body_2d.tscn")

var exp_pr = preload("res://actor/exp/exp.tscn")

func _ready() -> void:
	Signals.start_scene.connect(_on_start_scene)
	
func _on_start_scene(pre_data):
	print("start main:", pre_data)
	
	# 前シーンからデータ受け取る
	player_name = pre_data["player_name"]
	var mode = pre_data["mode"] # server or client
	
	if mode == "server":
		await Net.start_server()
		multiplayer.peer_connected.connect(_on_new_player)
		multiplayer.peer_disconnected.connect(_on_exit_player)
	else:
		await Net.start_client()
		player_spawn.rpc()
		Net.message.rpc(player_name+"が参加したよ。")
	
# 誰か来た。
func _on_new_player(player_id):
	pass

# 誰か帰った。
func _on_exit_player(player_id):
	# プレイヤーノードをけす
	var exit_player = $Players.get_node(str(player_id)) 
	var player_name = exit_player.get_node("PlayerName").text
	exit_player.queue_free()
	Net.message(player_name+"、またね。")

# プレイヤーを追加する。
@rpc("any_peer")
func player_spawn():
	var new_player_id = multiplayer.get_remote_sender_id()
	var node = player_pr.instantiate()
	node.name = str(new_player_id) # 名前を通してplayer_idを伝える。必須
	$Players.add_child(node)

# botを追加する。
var bot_n := -2
func bot_spawn():
	var node = player_pr.instantiate()
	node.name = str(bot_n) # player_idマイナスならBOT
	bot_n -= 1

@rpc("any_peer")
func add_expball(pos):
	for p in multiplayer.get_peers(): # 全員にお願いするときの書き方。
		_add_expball.rpc_id(p, pos)

@rpc("any_peer")
func _add_expball(pos):
	for i in range(50):
		var b = exp_pr.instantiate()
		b.global_position = pos
		var rand = Vector2( randf_range(-100, 100), randf_range(-100, 0))
		b.move(pos+rand)
		$Exps.add_child(b)
		
		
		
