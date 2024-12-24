extends Node

const PORT = 1111 # サーバのドア番号
const SERVER_IP = "127.0.0.1" #サーバの住所

var player_pr = load("res://actor/player/multiplayer_body_2d.tscn")

func _ready() -> void:
	# 前シーンからデータ受け取る
	var player_name = Scene.get_pre_data("player_name")
	var mode = Scene.get_pre_data("mode") # server or client
	
	if mode == "server":
		_on_title_room_pressed()
	else:
		_on_title_start_pressed(player_name)
	
# 部屋にあそびにいく (クライアントになる）
func _on_title_start_pressed(player_name):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, PORT)
	multiplayer.multiplayer_peer = peer
	
	await multiplayer.connected_to_server #接続完了まで待つ
	
	player_spawn.rpc()
	
	server_message.call_deferred(""+player_name+"が参加しました。")

		
# 部屋をつくる （サーバーになる）
func _on_title_room_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_new_player)
	multiplayer.peer_disconnected.connect(on_exit_player)

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
	
# 誰か遊びに来た。
func on_new_player(player_id):
	print("だれかあそびにきたよ プレイヤー番号:", str(player_id))

# 誰か帰った。
func on_exit_player(player_id):
	print("かえったよ プレイヤー番号: ", str(player_id) )
	$Players.get_node(str(player_id)).queue_free()

# システムメッセージ
@rpc
func server_message(text):
	for p in multiplayer.get_peers():
		_server_message.rpc_id(p, text)

@rpc("any_peer")
func _server_message(text):
	Signals.log.emit(text)
	print("sys_message:", text, multiplayer.get_remote_sender_id())
	
