extends Incident
class_name AllIncident

@export var incidents: Array[Incident]
var _current_incident: Incident
var resolved_count: int

# NO TIMER NEEDED, USE PARENT

func activate(time: float):
	super.activate(time)
	resolved_count = 0
	for incident in incidents:
		incident.resolved.connect(one_success)
		incident.activate(time)
		print(incident.name)


func deactivate(success: bool):
	super.deactivate(success)
	for incident in incidents:
		incident.resolved.disconnect(one_success)
	if success:
		print("All incident resolved ")
	else :
		print("At least one incident not resolved")


func one_success():
	resolved_count+=1
	print("One resolved")
	if resolved_count == incidents.size():
		deactivate(true)
