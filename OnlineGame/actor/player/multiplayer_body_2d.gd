#
# マルチプレイヤー用のプレイヤー2Dノードサンプル

# 機能：
# 同期マン持ち主＝プレイヤーのノードをつくる。（プレイヤーが同期元）
# キーの同期をしてくれる。

extends CharacterBody2D # 他のノードを継承しても良い

class_name MultiplayerBody2D

var player_id := 0
var bot = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# ノード名にプレイヤーIDを設定し、このノードの持ち主をそのプレイヤーIDに。（同期マンの同期元を変更）
# プレイヤーIDマイナスはBOTとして扱う。
func _enter_tree() -> void:
	player_id = int(str(name))
	if player_id > 1:
		bot = false
		set_multiplayer_authority(player_id)
	else:
		bot = true
		set_multiplayer_authority(1)

func _ready() -> void:
	if player_id == multiplayer.get_unique_id(): #自分のキャラか？
		$Camera.enabled = true
	else: #ほかのキャラ。
		$Camera.enabled = false # 他のキャラのカメラは無効。
		set_physics_process(false) #他のキャラは_physics_processしない。持ち主が実施。
		#$Hitbox/Shape.disabled = true #他のキャラは当たり判定しない。持ち主が判定。


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# サーバに削除依頼
func destroy():
	_destroy.rpc()

@rpc("any_peer")
func _destroy():
	queue_free()

# サーバにスポーン依頼をする例。
#static func spawn(_player_id, to_node):
#	_spawn.rpc(_player_id, to_node)

#@rpc("any_peer")
#static func _spawn(_player_id, to_node):
#	# 自分のクラス名を取得
#	var node = MultiplayerBody2D.new()
#	node.name = _player_id
#	to_node.add_child(node)

#func _physics_process(delta) -> void:
#	move_and_slide()

#var lerp_position : Vector2

func _process(delta) -> void:
	# 自分以外の位置のなめらか同期の例。　lerp_positionを同期マンで同期する場合。
	#if player_id != multiplayer.get_unique_id(): 
	#	position = lerp(position, lerp_position, 0.1)
	pass

#func death():
#	# 破壊された状態にする例
#	set_physics_process(false) #入力不可
#	$hitbox/shape.disabled = true #当たり判定無効化
#	$area/shape.disabled = true #当たり判定無効化
#	set_multiplayer_authority(1) #所有権をサーバに戻す
#	modulate.a = 0.0 #透明
