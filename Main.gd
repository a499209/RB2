extends Node2D
var step = 1000
var Points = {}
var mouse_down = false
var Places = {}
var Squares = {}
var colors = {
	"hotpink": [8,Color.hotpink],
	"red":  [8,Color.red],
	"blue":  [8,Color.cornflower],
	"green": [8,Color.green],
	"orangered":  [8,Color.orangered],
	"darkgreen":  [8,Color.darkgreen],
	"white":  [8,Color.white],
	"gold": [8,Color.gold],
	"cyan":  [8,Color.cyan]
}

onready var Ball = preload("res://ball.tscn")
onready var SQ = preload("res://square.png")

#func _process(delta):
#	$Label.text = str(Places)




func _ready():
	randomize()
	create_squares()
	create_points()
	for i in self.get_children():
		if i is Position2D:
			Points[i.name] = i.position
			Places[i.name] = null
#			Places["0"] = ""
		if i in get_tree().get_nodes_in_group("balls"):
			i.ident()

func create_squares():
	var name_counter = 0
	var x_pos = -100
	var y_pos = -100 
	for i in 3:
		x_pos = -100
		y_pos += 300
		for k in 3:
			x_pos += 300
			var Square = Sprite.new()
			Square.self_modulate.a = 0.1
			Square.texture = SQ
			Square.position = Vector2(x_pos, y_pos)
			Squares[name_counter] = Square
			name_counter += 1
			add_child(Square)
	print (Squares)


func create_points():
	var name_counter = 0
	var x_pos = 900
	var y_pos = 0 
	for l in 3:
		x_pos -= 900
		y_pos += 300 
		for k in 3:
			y_pos -= 300
			x_pos += 300
			for i in 3:
				x_pos -= 300
				y_pos += 100
				for j in 3:
					x_pos += 100
					var Point = Position2D.new()
					Point.position = Vector2(x_pos, y_pos)
					self.add_child(Point)
					if (name_counter+5)%9 != 0:
						var ball = Ball.instance()
						ball.position = Point.position
						ball.ball_color = get_color()
#						ball.get_node("Label").text = str(name_counter)
						self.add_child(ball)
#					Point.rect_min_size = Vector2(20,20)
#					Point.color = Color(0,0,0)
#					Point.rect_position = Vector2(x_pos, y_pos)
					Point.name = str(name_counter)
#					var t = Button.new()
#					ball.add_child(t)
#					t.text = str(name_counter)
#					t.rect_min_size = Vector2(99,99)
					name_counter += 1

func check_complete():
	var completed = {}
	for i in 9:
		var A = check_square(i)
		if A[0]:
			completed[i] = A[1]
	print(completed)
	for i in Squares.values():
		i.self_modulate = Color(1,1,1,0.1)
	for i in completed.keys():
		if i != null:
			Squares[i].self_modulate = completed[i]
	return completed

func check_square(num):
	var CH = [0, 1, 2, 5, 8, 7, 6, 3]
	for j in CH:
		if Places[str(num * 9 + j)] != Places[str(num * 9)] or Places[str(num * 9)] == null:
			return [false, Places[str(num * 9)]]
	return [true, Places[str(num * 9)]]

func get_color():
	var C = []
	for i in  colors.keys():
		if colors[i][0] > 0:
			C.append(i)
	C.shuffle()
	colors[C[0]][0] -=1
	return colors[C[0]][1] 
#	if colors[C[0]][0] > 0:
#		colors[C[0]][0] -=1
#		return C[0][1]
#	else:
#		get_color()

func roll_start(speed, clock, section):
	print(clock, speed)
	for i in get_tree().get_nodes_in_group("balls"):
		if int(section) == int(i.Cell) - int(i.Cell)%9:
			if not i.moving:
				i.start_moving(clock)
			else:
				i.set_speed(speed, clock)
		else:
			if not i.moving:
				i.avalible_to_move = false

	for i in get_tree().get_nodes_in_group("centers"):
		i.avalible_to_move = false

func step_add():
	step -= 1
	$Label2.text = str(step)

func roll_stop():
	for i in get_tree().get_nodes_in_group("balls"):
		i.stop()
		
#	for i in get_tree().get_nodes_in_group("centers"): ломает, но возможно нужно
#		i.avalible_to_move = true

#func storage_update():
#	for i in get_tree().get_nodes_in_group("balls"):
#		i.ident()
#
#func storage_clear():
#	for i in Places.keys():
#		Places[i] = null
##		Places["0"] = ""

func get_nearest_point():
	var P = null
	var delta_P = null
	var NP = null
	var MP = get_global_mouse_position()
	for i in Points.keys():
		P = Points[i]
		if delta_P == null or abs(P.x-MP.x) + abs(P.y-MP.y) < delta_P:
			NP = i
			delta_P = abs(P.x-MP.x) + abs(P.y-MP.y)
#	print(NP)
	return int(NP)

func clockwise_rotation(NP, U):
	print(NP%9," aa ",  U.x, U.y)
	if abs(U.x) > abs(U.y):
		if (NP%9) in [0, 1, 2] and U.x > 0: 
			return true
		elif (NP%9) in [6, 7, 8] and U.x <= 0:
			return true
	else:
		if (NP%9) in [2, 5, 8] and U.y > 0:
			return true
		elif (NP%9) in [0, 3, 6] and U.y <= 0:
			return true

		else: return false
#	return false
#
#	if not (NP - NP%9) in [1, 2, 5, 8] and U.x+U.y < 0:
#		return true
#	if not (NP - NP%9) in [0, 7, 6, 3] and U.x+U.y > 0:
#		return true
#	return false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		mouse_down = true
		get_nearest_point()
	if event is InputEventMouseButton and not event.pressed and mouse_down:
		mouse_down = false
		roll_stop()
	if event is InputEventMouseMotion and mouse_down:
		var NP = get_nearest_point()
		var U = event.get_relative()
		
		if abs(U.x) > 5 or abs(U.y) > 5:
#			roll_start(event.get_speed(), U.x + U.y > 0, str(NP - NP%9))
			roll_start(event.get_speed(), clockwise_rotation(NP, U), str(NP - NP%9))
