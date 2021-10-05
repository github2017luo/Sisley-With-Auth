@isTest public class API_Star_RCU_ControllerTest {
    @isTest static void getRecordTest() {
        Account acc = new Account(name='Test');
        insert acc;
        
        String s = API_Star_RCU_Controller.loadRecord(acc.Id);
        
        Test.startTest();
        
        System.assert(s != null);
        
        Test.stopTest();
    }

}