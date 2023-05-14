@tool
extends ItemList

var down_or_up_pressed = false
var is_down = true

var page_down_or_page_up_pressed = false
var enter_pressed = false



func _input(event):
	if !owner.visible:return
	if down_or_up_pressed: accept_event()
	if page_down_or_page_up_pressed: accept_event()
	if enter_pressed:
		print("enter pressed")
		accept_event()
	
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		$Deadzone.stop()
		is_down = Input.is_action_just_pressed("ui_down")
		down_or_up_pressed = true
		accept_event()
		
		select_next_or_prev(is_down)
		$Deadzone.start()
		
	if Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_up"):
		down_or_up_pressed = false
		$Timer.stop()


	# TODO: implement page up & page down
	if Input.is_action_just_pressed("ui_page_down") or Input.is_action_just_pressed("ui_page_up"):
		page_down_or_page_up_pressed = true
		var is_page_down = Input.is_action_just_pressed("ui_page_down")
		accept_event()

	if Input.is_action_just_released("ui_page_down") or Input.is_action_just_pressed("ui_page_up"):
		page_down_or_page_up_pressed = false

	
	if Input.is_action_just_pressed("ui_accept"):
		event = event as InputEventKey
		if event and event.keycode == KEY_SPACE: return

		enter_pressed = true
		accept_event()
		get_owner().insert_selected_option()
				

	if Input.is_action_just_pressed("ui_accept"):
		event = event as InputEventKey
		if event and event.keycode == KEY_SPACE: return

		enter_pressed = false


func select_next_or_prev(is_next: = true):
	var selected:int = get_selected_items()[0]
	deselect_all()
	
	if is_next:
		select(selected+1 if selected<item_count-1 else 0)
	else:
		select(selected-1 if selected>0 else item_count-1)

	ensure_current_is_visible()


func _on_timer_timeout():
	select_next_or_prev(is_down)

func _on_deadzone_timeout():
	if not down_or_up_pressed: return
	$Timer.start()
	

