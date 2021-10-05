public class API_Star_RCU_Controller {
    
    @AuraEnabled
    public static String loadRecord(String recordId) {
        System.debug('recordId => '+ recordId);
        
        //String str = '[{"Id":"88383839", "FirstName":"Guillaume", "LastName":"L’herminier", "Email":"test@gmail.com", "Phone":"0620121992", "Birthdate":"11/07/1993", "City": "Neuilly-Sur Seine"},{"Id":"88383840", "FirstName":"Guillaume", "LastName":"L’herminier", "Email":"test@gmail.com", "Phone":"0620121992", "Birthdate":"11/07/1993", "City": "Neuilly-Sur Seine"},{"Id":"88383841", "FirstName":"Guillaume", "LastName":"L’herminier", "Email":"test@gmail.com", "Phone":"0620121992", "Birthdate":"11/07/1993", "City": "Neuilly-Sur Seine"},{"Id":"88383842", "FirstName":"Guillaume", "LastName":"L’herminier", "Email":"test@gmail.com", "Phone":"0620121992", "Birthdate":"11/07/1993", "City": "Neuilly-Sur Seine"}]';
        String str = '[{"Row":[{"FieldName":"Id","FieldValue":"88383839"},{"FieldName":"FirstName","FieldValue":"Guillaume"},{"FieldName":"LastName","FieldValue":"L’herminier"},{"FieldName":"Email","FieldValue":"test@gmail.com"},{"FieldName":"Phone","FieldValue":"0620121992"},{"FieldName":"Birthdate","FieldValue":"11/07/1993"},{"FieldName":"City","FieldValue":"Neuilly-Sur Seine"}]},'
        + '{"Row":[{"FieldName":"Id","FieldValue":"88383840"},{"FieldName":"FirstName","FieldValue":"Guillaume"},{"FieldName":"LastName","FieldValue":"L’herminier"},{"FieldName":"Email","FieldValue":"test@gmail.com"},{"FieldName":"Phone","FieldValue":"0620121992"},{"FieldName":"Birthdate","FieldValue":"11/07/1993"},{"FieldName":"City","FieldValue":"Neuilly-Sur Seine"}]}]';
        
        return str;//(List<Object>)JSON.deserialize(str, List<Object>.class);
    }
}