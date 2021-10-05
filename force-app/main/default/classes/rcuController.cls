public class rcuController {
    
    @AuraEnabled
    public static String getRCU(String recordId) {
        System.debug('recordId => '+ recordId);
        
        String str = '{"Id":"88383839", "First Name":"Guillaume", "LastName":"L’herminier", "Email":"glherminier@baybridgedigital.com", "Phone":"0620121992", "Birthdate":"11/07/1993", "City": "Neuilly-Sur Seine"}';
        
        return str;
    }
}