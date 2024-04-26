class_name Sheep extends CharacterBody3D

# - 0 = not hungry, 1 = hungry
@export_range(0.0,1.0) var hunger : float = 0.0

# - how hungry the sheep gets per frame ? (maybe doing some form of animal_tick later on
@export_range(0.001,1.0) var metabolism : float = 0.001
@export_range(0.0,100.0) var health : float = 100.0

@export_range(0, 60.0) var tick_rate : int = 1 # abstract this to director  

@onready var grazer: Grazer = get_node("Grazer")

var tick_counter :int = 0# abstract this to director 

var hunger_threshold = 0.3
var excessive_eating_chance : int = 1000 # 1/value chance of eating randomly
enum states {
	ROAMING,
	EATING,
	STARING,	# when player is 10-20 m away
	EVADING,		# when player is running 10-20 m away or closer than 10m
	DEAD 			# when it starves to death
} 


var current_state : states
func think():
	# if hungry + on grass + not too near other entities
	if hunger <= 0.0:
		#dead!
		pass
	elif hunger > 0.1 and randi() % excessive_eating_chance == 0:
		# random eating
		change_state(states.EATING)
	elif hunger > 0.7:
		# eat if we arent evading
		change_state(states.EATING)

func _ready():
	randomize()
func _physics_process(delta):
	if tick_counter % tick_rate == 0:
		hunger += metabolism * randf_range(0,0.01)
		hunger = clamp(hunger, 0.0, 1.0)
		if (is_equal_approx(hunger, 1.0)):
			health -= 1.0 * randf_range(0.001,0.5)
			
		health = clamp(health, 0, 100.0)
		if(is_equal_approx(health, 0.0)):
			change_state(states.DEAD)
		#print(hunger)
		#print(health)
		
	tick_counter+= 1
	
	match current_state:
		
		states.ROAMING:
			pass#print("roaming about")
		states.EATING:
			pass#print("eating")
		states.DEAD:
			pass#print("DEAD - need to implement mechanism to clean up or decompose bodies")

func change_state(state : states):
	current_state = state
