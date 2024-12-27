# シーン切り替えマン　
# 自動読み込みにいれろ

extends Node

var pre_data :Dictionary # 前のシーンが残したデータ
var pre_scene = "" #前のシーン

# シーン制御用
signal on_end_scene()
signal on_change_scene(to, send_data, effect)
signal on_start_scene(pre_data)

func _ready() -> void:
	pass

# シーンを切り替え。データの受け渡しと切り替えトランジション。
func change_scene(to, send_data, effect):
	print("change scene: "+ pre_scene +" -> "+ to)
	
	on_end_scene.emit()
	on_change_scene.emit(to, send_data, effect)
	
	match effect: # 切り替えトランジションはここに書け
		"no effect":
			pass
	pre_data = send_data
	get_tree().change_scene_to_file.call_deferred(to)
	
	await get_tree().create_timer(0).timeout

	on_start_scene.emit(pre_data)
	
	pre_scene = to
	
func get_pre_data(key):
	if pre_data.has(key):
		return pre_data[key]
	return null

func _process(delta: float) -> void:
	pass
