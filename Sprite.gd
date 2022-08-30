extends Sprite
var avalible_to_move = true
var moving = false
var Clock
var Cell
var ball_color


#func _ready():
#	self_modulate = Color((randi()%10)/20.0+0.5,(randi()%10)/20.0+0.5,(randi()%10)/20.0+0.5)

#func _process(_delta):
#	$Label.text = cell

#func _process(delta):
#	if self in get_tree().get_nodes_in_group("balls"):
#		self_modulate = Color(0,1,1,0.5)
#	if self in get_tree().get_nodes_in_group("centers"):
#		self_modulate = Color(1,0,0,0.5)

#func _process(delta):
#	if avalible_to_move:
#		self_modulate = Color(0,1,1,0.5)
#	if not avalible_to_move:
#		self_modulate = Color(1,0,0,0.5)

func ident():
	self_modulate = ball_color
	for i in get_parent().Points.keys():
		if get_parent().Points[i] == self.position:
			Cell = i
			get_parent().Places[Cell] = ball_color
#	return Cell

func move_to_point(point):
	get_parent().Places[Cell] = null
	$Tween.interpolate_property(self, "position", self.position, get_parent().Points[point], 1 , Tween.TRANS_LINEAR)
	$Tween.start()

func start_moving(clock):
	Clock = clock
	if avalible_to_move:
		moving = true
		$Tween.stop_all()
		move_next_point()
		avalible_to_move = false

func set_speed(speed, clock):
	Clock = clock
#	Clock = speed.x + speed.y > 0 
	var SPD = sqrt(abs(speed.x/8) + abs(speed.y/8)) * 0.4
	$Tween.set_speed_scale(SPD)

func stop():
	moving = false

func _on_Tween_tween_all_completed():
	ident()
	get_parent(). check_complete()
	get_parent().step_add()
#	print("moving",moving)
	if moving:
		if self in get_tree().get_nodes_in_group("balls"):
			move_next_point()
	else:
		block_sides(false)
		avalible_to_move = true

#func move_previous_point():
#	if int(cell) > 1:
#		move_to_point(str(int(cell) - 1))
#	else:
#		move_to_point("8")

func move_next_point():
	var mov = [0, 1, 2, 5, 8, 7, 6, 3]
	var point
	var square =  int(Cell) - int(Cell)%9
#	if not avalible_to_move:
#		return false
	if Clock:
		if int(Cell)%9 != 3:
			point = mov[mov.find(int(Cell)%9) + 1]
			move_to_point(str(point + square))
		else:
			move_to_point(str(0 + square))
	else:
		if int(Cell)%9 != 0:
			point = mov[mov.find(int(Cell)%9) - 1]
			move_to_point(str(point + square))
		else:
			move_to_point(str(3 + square))


func find_free_place(cell):
	var Neighbours = get_neighbour(cell)
	if not is_center_of_block(cell):
		for i in get_parent().Places.keys():
			if i in Neighbours and  get_parent().Places[i] == null:
				return i
		for i in get_parent().Places.keys():
			if is_center_of_block(i) and in_same_block(i, cell) and get_parent().Places[i] == null:
				 return i
	else:
		for i in get_parent().Places.keys():
			if not is_center_of_block(i) and in_same_block(i, cell) and get_parent().Places[i] == null:
				return i

func block_sides(YN):
#	print("block", YN)
	for i in get_tree().get_nodes_in_group("balls"):
		i.avalible_to_move = !YN
	for i in get_tree().get_nodes_in_group("centers"):
		i.avalible_to_move = !YN

func is_center_of_block(cell):
	if (int(cell)+5)%9 == 0:
		return true
	else:
		return false

func in_same_block(cell1, cell2):
	if int(cell1) - int(cell1)%9 == int(cell2) - int(cell2)%9:
		return true
	else:
		return false

func get_neighbour(cell):
	var Neighbours = []
	var P_cell = get_parent().Points[str(cell)]
	for i in get_parent().Points.keys():
		var NB = get_parent().Points[i]
		if i!=str(cell) and abs(NB.x - P_cell.x) + abs(NB.y - P_cell.y) == 100 and not in_same_block(cell, i):
			Neighbours.append(i)
#	print(Neighbours)
	return Neighbours

func _on_TouchScreenButton_released():
	
	var place = find_free_place(int(Cell))
	
	if place == null: #если не находим пустого места, то прерываем цикл
		return false
#	block_sides(true)
	if avalible_to_move:
		block_sides(true)
		
		if self in get_tree().get_nodes_in_group("balls"):
			if is_center_of_block(place):
				self.add_to_group("centers")
				self.remove_from_group("balls")
				
			set_speed(Vector2(200,200), false)
			move_to_point(place)
			moving = false
			get_parent().Places[Cell] = null
		elif self in get_tree().get_nodes_in_group("centers"):
			move_to_point(place)
			self.add_to_group("balls")
			self.remove_from_group("centers")
