#
# シーン切り替えマン
#

extends Node
class_name Scene

var pre_data :Dictionary # 前のシーンが残したデータ
var pre_scene = "" #前のシーン

func _ready() -> void:
	Signals.change_scene.connect(_change_scene)

# シーンを切り替え。データの受け渡しと切り替えトランジション。
func _change_scene(to, send_data, effect):
	print("change scene: "+ pre_scene +" -> "+ to)
	
	Signals.end_scene.emit()
	
	match effect: # 切り替えトランジションはここに書け
		"no effect":
			pass
	pre_data = send_data
	get_tree().change_scene_to_file.call_deferred(to)
	
	await get_tree().create_timer(0).timeout

	Signals.start_scene.emit(pre_data)
	
	pre_scene = to
	
func get_pre_data(key):
	if pre_data.has(key):
		return pre_data[key]
	return null

func _process(delta: float) -> void:
	pass
