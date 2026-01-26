class_name LevelManager extends Node2D

@export var grid_system: GridSystem
@export var ghost_cursor: Node2D
@export var state_machine: StateMachine
@export var tile_map: TileMapLayer
@export var held_visual: Node2D
@export var inventory_bar: HBoxContainer

const SLOT_SCENE = preload("res://Scene/UI/InventorySlot.tscn")

func start_dragging_item(trash: TrashShape):
	state_machine._transition_to_next_state("Dragging", {"trash" : trash})

func add_random_item_to_inventory():
	var shape_data = GameData.get_random_shape()
	
	if shape_data:
		var new_slot = SLOT_SCENE.instantiate()
		inventory_bar.add_child(new_slot)
		
		new_slot.setup(shape_data)
			
		print("Added item: ", shape_data.atlas_id)

func add_item(shape_data: TrashShape):
	var new_slot = SLOT_SCENE.instantiate()
	inventory_bar.add_child(new_slot)
	new_slot.setup(shape_data)
