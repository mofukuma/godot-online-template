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

@onready var sprite = $Sprite

@export var lerp_position : Vector2

enum {JUMP, IDLE, WALK}
@export var state := JUMP
var state_frame := 0
var _old_state := JUMP

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

func _move_rand_spawn_pos():
	var randarea = $/root/Main/SpawnArea
	var rand = randarea.shape.size
	position.x = randarea.global_position.x + randf_range(-rand.x/2, rand.x/2)
	position.y = randarea.global_position.y + randf_range(-rand.y/2, rand.y/2)

func _ready() -> void:
	if multiplayer.is_server():
		pass
		
	elif player_id == multiplayer.get_unique_id(): #自分のキャラか？
		print("ready:", name, " ", player_id, " ", multiplayer.get_unique_id())
		$Camera.enabled = true
		$Camera.position_smoothing_enabled = true
		velocity = Vector2.ZERO
		
		_move_rand_spawn_pos()
		
		$PlayerName.text = Scene.get_pre_data("player_name")
		
	else: #ほかのキャラ。
		print("other:", name, " ", player_id, " ", multiplayer.get_unique_id(), lerp_position)
		velocity = Vector2.ZERO
		
		#$Hitbox/Shape.disabled = true #他のキャラは当たり判定しない。持ち主が判定。
	
		position = lerp_position
		

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player_id == multiplayer.get_unique_id(): #自分のキャラか？
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = (direction < 0)
			
			if is_on_floor():
				state = WALK
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				state = IDLE

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			state = JUMP
				
	move_and_slide()
			
	if player_id == multiplayer.get_unique_id(): #自分のキャラか？
		lerp_position = position	

# サーバに削除依頼
func destroy():
	_destroy.rpc()

@rpc("any_peer")
func _destroy():
	queue_free()

func _process(delta) -> void:
	if _old_state != state: # state変化時。
		state_frame = 0
		match state:
			JUMP:
				velocity.y = JUMP_VELOCITY
				sprite.play("jump")
			WALK:
				position = lerp_position # 位置の即同期
				sprite.play("walk")
			IDLE:
				position = lerp_position # 位置の即同期
				sprite.play("idle")
				
	# 自分以外の位置のなめらか同期の例。　lerp_xを同期マンで同期する場合。
	if player_id != multiplayer.get_unique_id():
		position.x = lerp(position.x, lerp_position.x, 0.5)
		if state != JUMP:
			position.y = lerp(position.y, lerp_position.y, 0.5)
	
	_old_state = state
	state_frame += 1

#func death():
#	# 破壊された状態にする例
#	set_physics_process(false) #入力不可
#	$hitbox/shape.disabled = true #当たり判定無効化
#	$area/shape.disabled = true #当たり判定無効化
#	set_multiplayer_authority(1) #所有権をサーバに戻す
#	modulate.a = 0.0 #透明
