trigger AccountTrigger on Account (after update, after insert) {
    TriggerDispatcher.entry('AccountTriggerHandler');
}