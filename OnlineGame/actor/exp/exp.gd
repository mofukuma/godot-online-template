extends Area2D

class_name Exp

@onready var org_scale := scale
var anim := randf()
var lerp_position := position

signal destroy

func init(global_pos, move_pos):
	position = global_pos
	lerp_position = global_pos + move_pos

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	$Shape.disabled = false
	
	destroy.connect(_destory)

func _destory():
	for i in range(10):
		modulate.a -= 0.1
		scale += Vector2(0.3,0.3)
		await get_tree().create_timer(0).timeout
		
	queue_free()

func _process(delta):
	anim += delta *10
	scale = org_scale + Vector2(sin(anim), sin(anim))*0.1
	
	position = lerp(position, lerp_position, delta * 5)
