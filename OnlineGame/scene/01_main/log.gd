extends RichTextLabel

# signalで受け取ったメッセージログを表示する

@onready var Net : Net = $/root/Import/Net

var log_text : Array = []
var show_remain := 0.0
const SHOW_MAX = 3
const LOG_MAX = 50

func _ready() -> void:
	#Net.on_message.connect(print_log) # メッセージ発生イベントに接続
	self.text = ""

func _process(delta: float) -> void:
	show_remain -= delta
	if show_remain < 0:
		visible = false
	else:
		visible = true

func print_log(message)-> void:
	log_text.push_front(message)
	
	#最大表示数を超えたら古いものを消す
	if log_text.size() > LOG_MAX:
		log_text.pop_back()
		
	self.text = str("\n".join(log_text))
	show_remain = SHOW_MAX
