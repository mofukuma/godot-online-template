# シーンを変えても消えない永続ノードにする
# ーーーーーーーー

extends Node

func _ready():
	if $/root/Perma.has_node(str(name)): #すでにあったら何もせず消える
		queue_free()
	else:
		self.reparent.call_deferred($/root/Perma) # 無ければ永続ノードにする
