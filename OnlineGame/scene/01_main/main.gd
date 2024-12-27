extends Node

# import
@onready var Net : Net = $/root/Import/Net

var player_name = ""
var player_pr = preload("res://actor/player/multiplayer_body_2d.tscn")
var exp_pr = preload("res://actor/exp/exp.tscn")

func _ready() -> void:
	Scene.on_start_scene.connect(_on_start_scene)
	pop_exp()
	
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
		Net.message(player_name+"が参加したよ。")
	
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

# 経験値玉がわく
func pop_exp():
	while true:
		if $Exps.get_child_count() < 100:
			var b = exp_pr.instantiate()
			var area = $Ground/StaticBody2D/Shape
			var rand = area.shape.size
			b.init(area.global_position + Vector2(randf_range(-rand.x/2, rand.x/2), randf_range(-rand.y/2, rand.y/2) - rand.y) ,Vector2(0.0, 0.3))
			$Exps.add_child(b)
		await get_tree().create_timer(1.0).timeout

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
