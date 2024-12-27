#
# マルチプレイヤー用のプレイヤー2Dノードサンプル

# 機能：
# 同期マン持ち主＝プレイヤーのノードをつくる。操作プレイヤーが同期元にする。
# 左右の位置同期と、上下の位置同期を分けて管理。（なめらかなジャンプ）
# 相手を踏んだら倒せる。

extends CharacterBody2D # 他のノードを継承しても良い

class_name MultiplayerBody2D

# import
@onready var Net : Net = $/root/Import/Net

var player_id := 0 #peerのID
var bot = false # botかな？
var me = false # 自分が操作しているキャラかな？

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var sprite = $Sprite

@export var lerp_position : Vector2 #同期

enum {JUMP, AIR_JUMP, IDLE, WALK, SKILL_HIJUMP, DIE}
@export var state := IDLE  #同期
var state_frame := 0
var old_state := JUMP

const DOUBLE_JUMP := 2
var jump_remain := 0

const SKILL_HIJUMP_COOLDOWN = 7.0
var skill_hijump_cooldown := 0.0

var org_scale: Vector2

var exp_pr = preload("res://actor/exp/exp.tscn")

# ノード名にプレイヤーIDを設定し、このノードの持ち主(authority)に。
# プレイヤーIDマイナスはBOTとして扱う。
func _enter_tree() -> void:
	player_id = int(str(name))
	if player_id > 1:
		bot = false
		set_multiplayer_authority(player_id)
	else:
		bot = true
		set_multiplayer_authority(1)
	
	org_scale = scale

func _move_rand_spawn_pos(randarea):
	var rand = randarea.shape.size
	position.x = randarea.global_position.x + randf_range(-rand.x/2, rand.x/2)
	position.y = randarea.global_position.y + randf_range(-rand.y/2, rand.y/2)
	lerp_position = position

func _ready() -> void:
	$Shape.disabled = true # 出現してしばらくはあたり判定OFF
	modulate.a = 0.0 # 出現してしばらくは見えない
	
	if multiplayer.is_server():
		pass
		
	elif player_id == multiplayer.get_unique_id(): #自分のキャラか？
		me = true
		
		$Camera.enabled = true
		
		scale = org_scale
		
		_move_rand_spawn_pos( $/root/Main/PlayerSpawnArea )
		
		$PlayerName.text = $/root/Main.player_name
		#$Humi/Shape.disabled = true
		$Humi/Shape.disabled = false
		
		state = JUMP
		
	else: #ほかのキャラ。
		$Humi/Shape.disabled = true
		#$Humi/Shape.disabled = false
		
		position = lerp_position
	
	await get_tree().create_timer(0.3).timeout
	$Shape.disabled = false #あたり判定　ON
	$Camera.position_smoothing_enabled = true
	modulate.a = 1.0


func _physics_process(delta: float) -> void:
	# 同期のポイント　なめらか同期。
	# 上下、重力やジャンプはvelocityで各クライアントで計算。
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 操作関連---------------
	if me and state != DIE: #自分のキャラだけが操作できる & 死んでないとき
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			sprite.flip_h = (direction < 0)
			
			if is_on_floor() and state_frame > 5: #JUMP直後に着地しないように
				state = WALK
				jump_remain = DOUBLE_JUMP
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor() and state_frame > 5:
				state = IDLE
				jump_remain = DOUBLE_JUMP

		if Input.is_action_just_pressed("ui_accept"): # ジャンプの処理
			if is_on_floor():
				$Jump.play()
				state = JUMP
				jump_remain -= 1
			elif jump_remain > 0:
				$Jump.play()
				state = AIR_JUMP
				jump_remain -= 1
				
		if Input.is_action_just_pressed("hijump") and skill_hijump_cooldown < 0.0: # スキル使用。ハイジャンプ
			$Jump.play()
			state = SKILL_HIJUMP
			skill_hijump_cooldown = SKILL_HIJUMP_COOLDOWN
				
	move_and_slide()
			
	if me: #自分のキャラなら同期用の変数へセット
		lerp_position = position
		
func _process(delta) -> void:
	# stateが変化したときに1回実行する------------
	if old_state != state: 
		state_frame = 0
		
		match state:
			JUMP:
				velocity.y = JUMP_VELOCITY - (scale.y * 100 )
				sprite.play("jump")
			SKILL_HIJUMP:
				velocity.y = JUMP_VELOCITY*2
				sprite.play("jump")
			AIR_JUMP:
				velocity.y = JUMP_VELOCITY- (scale.y * 100 )
				sprite.play("jump")
			WALK:
				sprite.play("walk")
			IDLE:
				sprite.play("idle")
			DIE:
				# しんだとき
				$TankBreak.play()
				velocity = Vector2.ZERO
				scale.y = 0.02
				
				# 経験値玉まきちらし（経験値玉の位置は同期しません。こういう設計も重要です）
				var ball_n : int = scale.x * 30
				for i in range(ball_n):
					var ball = exp_pr.instantiate()
					ball.init(global_position, Vector2( randf_range(-20, 20), randf_range(-10, 0) ) * ball_n )
					$/root/Main/Exps.add_child(ball)
		
		position = lerp_position # stateが変化したとき位置の即同期
	# ------------
				
	# 自分以外の位置のなめらか同期の例。
	if not me:
		position.x = lerp(position.x, lerp_position.x, 0.8)
		if not(state == JUMP or state == AIR_JUMP or state == SKILL_HIJUMP): 
			# ジャンプしてないときだけなめらか同期。ジャンプは重力に従うほうがなめらか。
			position.y = lerp(position.y, lerp_position.y, 0.8)
	
	# スキルの処理
	skill_hijump_cooldown -= delta
	
	old_state = state
	state_frame += 1


# 自分を破壊された状態にする
@rpc("any_peer")
func death():
	state = DIE
	$Camera.position_smoothing_enabled = false
	modulate.a = 0.5
	await get_tree().create_timer(0).timeout
	$TakeItemArea/Shape.disabled = true
	
	Signals.game_over.emit()
	
	await Signals.retry
	
	_ready()
	$TakeItemArea/Shape.disabled = false


# 誰かをふんだぞ
func _on_humi_body_entered(body: Node2D) -> void:
	if body == self or not me or state == DIE:
		return
	if body is MultiplayerBody2D:
		if me and body.state != DIE: # 自分のときだけ処理。
			body.death.rpc_id(body.player_id) # 相手を破壊された状態にするようにお願い
			Net.message(body.get_node("PlayerName").text +"が、" + $PlayerName.text+"に踏まれた！" )
			await get_tree().create_timer(0).timeout
			$Humi/Shape.disabled = false #踏みディレイ
			await get_tree().create_timer(0.3).timeout
			$Humi/Shape.disabled = true

# アイテムとった
func _on_take_item_area_area_entered(area: Area2D) -> void:
	if area is Exp:
		if state == DIE:
			return 
		
		area.destroy.emit()
		
		if me:
			$ExpGet.play()
			scale += Vector2(0.015, 0.015)
	
