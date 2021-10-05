trigger AssignedResourceTrigger on AssignedResource (after update, after insert) {
TriggerDispatcher.entry('AssignedResourceTriggerHandler');
}