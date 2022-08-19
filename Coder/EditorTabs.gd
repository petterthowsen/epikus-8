extends TabContainer

func grab_focus():
	if get_child_count() > 0:
		get_child(current_tab).grab_focus()
