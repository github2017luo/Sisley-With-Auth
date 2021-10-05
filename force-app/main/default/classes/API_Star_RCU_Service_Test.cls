@isTest global class API_Star_RCU_Service_Test {
    
    @isTest static void searchAccountsTest(){
        Account acc = new Account();
        acc.Name = 'Name';
        insert acc;
        
        String s = API_Star_RCU_Service.searchAccountsRCU(acc.Id);
        Test.startTest();
        System.assert(s !=null);
        Test.stopTest();
    }
	/*
    @isTest static void testSynchronize() {
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        API_Star_RCU_Service.synchronize(acc.Id,'B000000120');
        
        acc = [SELECT Id, ID_RCU__pc  FROM Account Where id =: acc.Id];
        
        Test.startTest();
        System.assert(acc.ID_RCU__pc  != null);
        Test.stopTest();
        
    }
    
        
    @isTest static void testCreateCustomer() {
        
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
        
        API_Star_RCU_Service.createCustomer(acc.Id);
        
        acc = [SELECT Id, ID_RCU__pc  FROM Account Where id =: acc.Id];
        
        Test.startTest();
        System.assert(acc.ID_RCU__pc  != null);
        Test.stopTest();
        
    }
    
            
    @isTest static void testUpdateCustomer() {
        
        Account acc = new Account();
        acc.name = 'test';
        acc.ID_RCU__pc = '1234';
        insert acc;
        
        API_Star_RCU_Service.updateCustomer(acc.Id);
        
        Account accUpdate = [SELECT Id, ID_RCU__pc  FROM Account Where id =: acc.Id];
        
        Test.startTest();
        System.assert(acc.ID_RCU__pc != accUpdate.ID_RCU__pc);
        Test.stopTest();
        
    }
    
    @isTest static void testGetProduct() {
        
        String prod = API_Star_RCU_Service.getProduct('B000000120');
        
        Test.startTest();
        System.assert(prod != null);
        Test.stopTest();
        
    }   
    
    @isTest static void testUpdateProduct() {
        Product2 product = new Product2();
        product.name = 'test';
        product.ID_RCU__c = 'B000000120';
		insert product;
        
        API_Star_RCU_Service.updateProduct(product.ID_RCU__c);
        Product2 prod = [SELECT ID_RCU__c FROM Product2 WHERE ID_RCU__c = 'B000000120'];
        Test.startTest();
        System.assert(prod.ID_RCU__c == product.ID_RCU__c);
        Test.stopTest();
        
    }
	*/

    
    
}