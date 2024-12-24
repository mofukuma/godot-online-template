extends RichTextLabel

var log_text : Array = []

func _ready() -> void:
	Signals.log.connect(print_log)
	log_text.append("test start")
	self.text = str("\n".join(log_text))
	
	while true:
		await Signals.log
		self.text = str("\n".join(log_text))

func print_log(message):
	print("log:", message)
	log_text.append(message)
	
	queue_redraw()
