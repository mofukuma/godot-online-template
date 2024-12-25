# /root/Global　以下にモジュールシステムを構築
# 子をシーンを変えても消えない永続ノードにする
# グローバルモジュールのインポートもこれでやる
#
# モジュールを使うときはこんな感じでインポートしよう
# @onready var Scene : Scene = $/root/Global/Scene
# ーーーーーーーー

extends Node

func _ready():
	var globalname = str(name)
	for child in get_children():
		exist_move(child, $/root.get_node(globalname))
	queue_free.call_deferred()

func exist_move(node, target_parent):
	if not target_parent.has_node(str(node.name)):
		node.reparent(target_parent) # 無ければ永続ノードにする
		return
	else:
		node.queue_free.call_deferred()
		
	var target_node = target_parent.get_node(str(node.name))
	
	for child in node.get_children():
		exist_move(child, target_node)
