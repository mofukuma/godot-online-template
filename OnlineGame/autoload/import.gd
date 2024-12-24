#
# シーンにImportを入れておくと、$/root/Importにロードしてくれる
#
extends Node

# プログラムからモジュールロード
func import(module_path):
	var node = load(module_path)
	if $/root/Import.has_node(str(node.name)):
		$/root/Import.add_child(node)

func _ready() -> void:
	var modules = get_children()
	if modules.size() == 0:
		return
	for m in modules:
		if $/root/Import.has_node(str(m.name)):
			pass
		else:
			m.reparent($/root/Import)
	
	queue_free()

func _process(delta: float) -> void:
	pass
