#
# シーン切り替え
#

extends Node

var pre_data :Dictionary # 前のシーンが残したデータ

func _enter_tree() -> void:
	Signals.change_scene.connect(_change_scene)

# シーンを切り替え。データの受け渡しと切り替えトランジション。
func _change_scene(to, send_data, effect):
	print("change scene")
	
	Signals.end_scene.emit()
	
	match effect: # 切り替えトランジションはここに書け
		"no effect":
			pass
	pre_data = send_data
		
	get_tree().change_scene_to_file.call_deferred(to)
	
	Signals.start_scene.emit.call_deferred(pre_data)
	
	return pre_data

func get_pre_data(key):
	if pre_data.has(key):
		return pre_data[key]
	return null


func _process(delta: float) -> void:
	pass
