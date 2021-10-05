@isTest
public class ApiServiceHandlerTest {
    @isTest static void createConnectLinkTest() {
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        ServiceAppointment s = new ServiceAppointment();
        s.ParentRecordId = acc.id;
        s.Bambuser_API_Key__c = '8f4zPgFAiHmxGFmEyycWcHZeLZYquW9umigxseNQ6KkY';
        s.Country__c = 'France';
        
        insert s;
        
        ApiServiceHandler.createNewConnectLink(s.Id);
        ServiceAppointment sAfterInsert = [Select id, Country__c from ServiceAppointment where id = :s.Id];  
        Test.startTest();
        
        System.assertEquals(sAfterInsert.Country__c, 'France');
        
        Test.stopTest();
        
    }
    
    @isTest static void createVoiceManagementTest() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        ServiceAppointment s = new ServiceAppointment();
        s.ParentRecordId = acc.id;        
        insert s;
        
        
        
        ApiServiceHandler.createVoiceManagement(s.Id);
       // ServiceAppointment sAfterInsert = [Select id, Country__c from ServiceAppointment where id = :s.Id];  
        Test.startTest();
        
       // System.assertEquals(sAfterInsert.Country__c, 'France');
        
        Test.stopTest();
        
    }
    
    @isTest static void getPhoneCountyCodeTest() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        ServiceAppointment s = new ServiceAppointment();
        s.ParentRecordId = acc.id;
        s.Bambuser_API_Key__c = '8f4zPgFAiHmxGFmEyycWcHZeLZYquW9umigxseNQ6KkY';
        s.Country__c = 'France';
        
        insert s;
        
        String str = ApiServiceHandler.getPhoneCountyCode('0620121992','33');
        //ServiceAppointment sAfterInsert = [Select id, Country__c from ServiceAppointment where id = :s.Id];  
        Test.startTest();
        
        System.assertEquals(str,'33620121992');
        
        Test.stopTest();
        
    }
    
    @isTest static void getIdFromResponseTest() {
       
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        ServiceAppointment s = new ServiceAppointment();
        s.ParentRecordId = acc.id;
        s.Bambuser_API_Key__c = '8f4zPgFAiHmxGFmEyycWcHZeLZYquW9umigxseNQ6KkY';
        s.Country__c = 'France';
        
        insert s;
        
        String jsonString = '{ "id": "B2KMttRLCDtFYh0DnlpV", "validFrom": "2021-07-28T10:00:00.000Z", "validTo": "2021-07-31T10:00:00.000Z"}';
        
        String str = ApiServiceHandler.getIdOutCallFromResponse(jsonString, '0620121992');
        Test.startTest();
        
        System.assert(str != null);
        
        Test.stopTest();
        
    }
}