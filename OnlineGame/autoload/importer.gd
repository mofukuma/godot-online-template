# /root/Import　以下に移動するだけのモジュールシステム
# この子ノードをシーンを変えても消えない永続ノードにする
# モジュールのインポートもこれでやる
#
# モジュールを使うときはこんな感じでインポートしよう!!
# @onready var SaveMan : SaveMan = $/root/Import/SaveMan
# ーーーーーーーー

extends Node
class_name Importer

func _enter_tree() -> void:
	for child in get_children():
		exist_move(child, $/root/Import)
	queue_free.call_deferred()

func exist_move(node, target_parent):
	if not target_parent.has_node(str(node.name)):
		node.reparent(target_parent)
		return
	else:
		node.queue_free.call_deferred()
		
	var target_node = target_parent.get_node(str(node.name))
	
	for child in node.get_children():
		exist_move(child, target_node)
