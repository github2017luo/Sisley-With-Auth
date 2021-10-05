public without sharing class ServiceAppointmentTriggerHandler implements TriggerDispatcher.ITriggerEntry{
    public void prepareData(){}
    public void beforeDelete(){}
    public void afterUpdate(){} 
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void afterInsert(){
        handleAppointmentTypeChange();
    }
    public void beforeInsert(){}
    public void beforeUpdate(){}
    
    public void handleAppointmentTypeChange() {
        List<ServiceAppointment> types = Trigger.new;
        //Map<Id, ServiceAppointment> oldMap = (Map<Id, ServiceAppointment>) Trigger.oldMap;
        
        for(ServiceAppointment s : types) {
            String recordId = s.Id;
            if(s.AppointmentType == 'Call') {
                ApiServiceHandler.createVoiceManagement(recordId);
            }
            if(s.AppointmentType == 'Video' ) {
                ApiServiceHandler.createNewConnectLink(recordId);
            }
            
        }
    }
    
}