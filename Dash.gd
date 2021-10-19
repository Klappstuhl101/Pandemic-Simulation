extends Panel

var label

var timer

var pause
var play
var playspeedx2
var texturebutton

var tenthsec

# Called when the node enters the scene tree for the first time.
func _ready():
	label = get_node("Label")
	
	timer = get_node("Time")
	
	pause = get_node("Pause")
	play = get_node("Play")
	playspeedx2 = get_node("PlaySpeedx2")
	
	texturebutton = get_node("TextureButton")
	
	pause.connect("pressed", self, "_on_Pause_pressed")
	play.connect("pressed", self, "_on_Play_pressed")
	playspeedx2.connect("pressed", self, "_on_PlaySpeedx2_pressed")
	
	texturebutton.connect("pressed", self, "_on_TextureButton_pressed")
	
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "_on_Time_timeout")
	
	
# Bitmap erstellen für Click Mask
	var bayern_image = Image.new()
	bayern_image.load("res://resources/Deutschland_Lage_von_Bayern.png")
	var bayern_bitmap = BitMap.new()
	bayern_bitmap.create_from_image_alpha(bayern_image)
#	for i in range(0,bayern_bitmap.get_size().x):
#		for j in range(0,bayern_bitmap.get_size().y):
#			print(String(bayern_bitmap.get_bit( Vector2(i,j) )))
#			print(i,j)
		
	texturebutton.texture_click_mask = bayern_bitmap
#	print(bayern_bitmap)
	
#	var loadedImage = Image.new()
#	loadedImage.load("res://icon.png")
#	var tst = BitMap.new()
#	tst.create_from_image_alpha(loadedImage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_TextureButton_pressed():
	label.text = "Bayern"

func _on_Pause_pressed():
	label.text = "Pause"
	timer.stop()
	pass
	
func _on_Play_pressed():
	label.text = "Play"
	timer.start()
	pass
	
func _on_PlaySpeedx2_pressed():
	label.text = "x2"
	pass


func _on_Time_timeout():
	label.text = "Hallo"
#	pass
#	tenthsec += 1
#	if tenthsec == 10:
#		sec +=1
#		tenthsec = 0
#	label.text = str(sec) + "," + str(tenthsec) + " seconds elapsed since button press"
