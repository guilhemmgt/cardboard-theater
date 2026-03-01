extends Incident
class_name RandomIncident

@export var incidents: Array[Incident]
var _current_incident: Incident

# NO TIMER NEEDED, USE PARENT

func activate(time: float):
	super.activate(time)
	if incidents:
		_current_incident = incidents.pick_random()
		_current_incident.resolved.connect(deactivate_success)
		_current_incident.activate(time)

func deactivate(success: bool):
	super.deactivate(success)
	_current_incident.resolved.disconnect(deactivate_success)
	
func deactivate_success():
	deactivate(true)
