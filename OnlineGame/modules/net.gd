
# 接続周りを関数一発で解決するマン
# 以下でインポートして
# @onready var Net : Net = $/root/Import/Net
# 
# 以下でサーバ、クライアントになる
# await Net.start_server()
# await Net.start_client()

# みんなにメッセージをおくる
# Net.message(text)

extends Node
class_name Net

var PORT = 1111 # サーバのドア番号
var SERVER_IP = "127.0.0.1" #サーバの住所
var server_url = SERVER_IP
enum {ENET, WEBSOCKET}
const MODE := WEBSOCKET

signal on_message(text) #メッセージ発生イベント

func _ready() -> void:
	if OS.has_feature("editor"): # エディタのときはローカルサーバにしとく
		SERVER_IP = "127.0.0.1"
		
	# 接続方法別の書き方の違いを吸収。
	match MODE:
		WEBSOCKET:
			server_url = SERVER_IP+":"+str(PORT)
			
			if OS.has_feature("web"): #ブラウザで公開するときはwebsockets
				server_url = "wss://"+SERVER_IP+":"+str(PORT) 

# 部屋にあそびにいく (クライアントになる）
func start_client():
	var peer
	match MODE:
		ENET:
			peer = ENetMultiplayerPeer.new()
			peer.create_client(SERVER_IP, PORT)
		WEBSOCKET:
			peer = WebSocketMultiplayerPeer.new()
			peer.create_client(server_url)
			
	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server #接続完了まで待つ
	
		
# 部屋をつくる （サーバーになる）
func start_server():
	var peer
	match MODE:
		ENET:
			peer = ENetMultiplayerPeer.new()
			peer.create_server(PORT)
		WEBSOCKET:
			peer = WebSocketMultiplayerPeer.new()
			peer.create_server(PORT)
			
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_new_player)
	multiplayer.peer_disconnected.connect(_on_exit_player)
	
	
# 誰か遊びに来た。
func _on_new_player(player_id):
	print("だれかあそびにきたよ プレイヤー番号:", str(player_id))

# 誰か帰った。
func _on_exit_player(player_id):
	print("かえったよ プレイヤー番号: ", str(player_id) )

#メッセージの表示
func message(text):
	if multiplayer.is_server():
		_send_message(text)
	else:
		_send_message.rpc(text)

# メッセージをみんなにおくる
@rpc("any_peer")
func _send_message(text):
	for p in multiplayer.get_peers(): # 全員にお願いするときの書き方。
		__send_message.rpc_id(p, text)

@rpc("any_peer")
func __send_message(text):
	var date = Time.get_datetime_dict_from_system()
	var text_zeropad = str(date["hour"]).pad_zeros(2)+":"+str(date["minute"]).pad_zeros(2)+":"+str(date["second"]).pad_zeros(2)+" "+text
	
	on_message.emit(text_zeropad) # 表示はsignalを通して表示してもらう。
	
