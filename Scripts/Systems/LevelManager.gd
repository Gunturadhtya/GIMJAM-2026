class_name LevelManager extends Node2D

@export var grid_system: GridSystem
@export var ghost_cursor: Node2D
@export var state_machine: StateMachine
@export var tile_map: TileMapLayer
@export var held_visual: Node2D
@export var inventory_bar: HBoxContainer

const SLOT_SCENE = preload("res://Scene/UI/InventorySlot.tscn")

func start_dragging_item(slot_node: PanelContainer):
	state_machine._transition_to_next_state("Dragging", {"slot_node" : slot_node})

func add_random_item_to_inventory(): # addd random item from /Data
	var shape_data = GameData.get_random_shape()
	
	if shape_data:
		var new_slot = SLOT_SCENE.instantiate()
		inventory_bar.add_child(new_slot)
		
		new_slot.setup(shape_data)
			
		print("Added item: ", shape_data.atlas_id)

func add_item(item: Container):
	inventory_bar.add_child(item)
