public class WSController {
    
    @AuraEnabled
    public static void foo(String recordId) {
        try {
            
            List<Account> accounts = [SELECT ID_RCU__pc From Account WHERE Id =: recordId];
            Account acc = accounts[0];
            List<Order__c> orderList = [SELECT ID_RCU__c, ID_SFCC__c From Order__c WHERE Id =: acc.Id];
            
            //System.debug('acc => ' + acc);
            //System.debug('orderList => ' + orderList);
            //return recordId;
        }
        
        catch (DmlException e){
            System.debug('DmlException=> ' + e.getMessage());
        }  
        
        catch (Exception e) {
            System.debug('Exception => ' + e.getMessage());
            
        }
    }
    
}