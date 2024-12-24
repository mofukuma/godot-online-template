extends Node2D

@export var speed := 6.0
@export var init_position : Vector2
@export var player_id := 0

var lifetime := 3.0

func _ready():
	position = init_position
	
func _physics_process(delta):
	position += Vector2.from_angle(rotation) * speed
	
	if multiplayer.is_server(): # サーバのときは消滅処理をする
		lifetime -= delta
		if lifetime <= 0.0:
			queue_free()

@rpc("any_peer")
func delete_this():
	queue_free()

func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	#if body is Target:
	#	#自分の弾のとき
	#	if player_id == multiplayer.get_unique_id():
	#		body.damaged.emit()
	#		delete_this.rpc_id(1)
		
	#if body is Tank:
	#	#当たったのが自分の戦車で、自分の弾ではないとき
	#	if body.player_id == multiplayer.get_unique_id() and player_id != multiplayer.get_unique_id() :
	#		body.damaged.emit()
	#		delete_this.rpc_id(1)
			
