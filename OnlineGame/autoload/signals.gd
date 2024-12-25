# 全体で使用する神シグナル。自動読み込みに追加すること
# システム周り処理やシーンを跨ぐ処理など、全体で使う処理をわかりやすくまとめよう
# ーーーーーーーー
 
extends Node

signal log(text) #ログ出す

# シーン制御
signal end_scene
signal change_scene(to, send_data, effect)
signal start_scene(pre_data)
