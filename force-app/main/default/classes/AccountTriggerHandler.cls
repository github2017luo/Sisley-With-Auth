public without sharing class AccountTriggerHandler implements TriggerDispatcher.ITriggerEntry {
    
    public void prepareData(){}
    public void beforeDelete(){}
    public void afterUpdate(){
        handleAccount();
    }
    public void afterDelete(){}
    public void afterUnDelete(){}
    public void afterInsert(){
        handleAccount();
    }
    public void beforeInsert(){}
    public void beforeUpdate(){}
    
    
    private static void handleAccount() {
		/*
        Set<Id> accIds = new Set<Id>();
        for(Account acc : (List<Account>) Trigger.New) {
            accIds.add(acc.Id);
        }
        
        List<Account> accs = [SELECT Id FROM Account WHERE Id IN :accIds];
       
        List<Account> accsToSendRequest = new List<Account>();
       
        for(Account acc : accs) {
            accsToSendRequest.add(acc);
        }
        
        update accsToSendRequest;
        */
	}
}