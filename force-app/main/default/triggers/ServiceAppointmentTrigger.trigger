trigger ServiceAppointmentTrigger on ServiceAppointment (before insert,after insert ,after update, before update, before delete, after delete) {
	TriggerDispatcher.entry('ServiceAppointmentTriggerHandler');
}