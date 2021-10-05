public without sharing class AssignedResourceTriggerHandler implements TriggerDispatcher.ITriggerEntry{
    public void prepareData(){}
    public void beforeDelete(){}
    public void afterUpdate(){
        handleAssignedResource();
    }
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void afterInsert(){
        handleAssignedResource();
    }
    public void beforeInsert(){}
    public void beforeUpdate(){}

    public void handleAssignedResource() {
        for(AssignedResource ar : (list<AssignedResource>)Trigger.New){
            System.debug('ar= '+ar);
            System.debug('ar= '+ar.serviceresourceid);
            System.debug('ar= '+ar.serviceresource.RelatedRecordId);
            if(ar.serviceresourceid!=null){
                ApiServiceHandler.createVoiceManagement(ar.id);
            }
        }
    }

 }