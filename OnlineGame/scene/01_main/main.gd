extends Node

const PORT = 1111 # サーバのドア番号
const SERVER_IP = "127.0.0.1" #サーバの住所

func _ready() -> void:
	Signals.log.connect(print_log)
	
	var player_name = Scene.get_pre_data("player_name") # 前シーンからデータ受け取る
	print(player_name)
	
func _on_title_start_pressed(entername):
	# 部屋にあそびにいく (クライアントになる）
	if multiplayer.get_peers().size() == 0: # まだ未接続なら
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(SERVER_IP, PORT)
		multiplayer.multiplayer_peer = peer
		
		await multiplayer.connected_to_server #接続完了まで待つ
		
	else: # 接続していたら
		destroy.rpc_id(1, multiplayer.get_unique_id())
		await get_tree().create_timer(0.5).timeout
		
func _on_title_room_pressed():
	# 部屋をつくる （サーバーになる）
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_new_player)
	multiplayer.peer_disconnected.connect(on_exit_player)
	
func player_spawn(player_id):
	var tank_pr = load("res://tank/tank.tscn")
	var tank = tank_pr.instantiate()
	tank.name = str(player_id)
	$Players.add_child(tank)
	
# 誰か遊びに来た。
func on_new_player(player_id):
	print("だれかあそびにきたよ プレイヤー番号:", str(player_id))
	player_spawn(player_id)

# 誰か帰った。
func on_exit_player(player_id):
	print("かえったよ プレイヤー番号: ", str(player_id) )
	$Players.get_node(str(player_id)).queue_free()

# サーバーに消すのをお願いする
# MultiplayerSpawner（スポーンマン）はサーバーでスポーンしたり消したりしたノードだけ同期するため。
@rpc("any_peer")
func destroy(player_id):
	$Players.get_node(str(player_id)).queue_free()

var log_text := []
func print_log(text):
	log_text.append(text)
	%Log.text = "\n".join(log_text)
	
