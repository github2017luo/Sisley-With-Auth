global class ApiServiceHandler {

    /*
    * @Method createNewConnectLink
    *
    * @Goal: send ConnectLink object (@see class at the buttom) to bumbuser API
    * Steps:
    * 1.Set the current apiKey according to country name (Metadata)
    * 2.Send POST request and catch the id on the response
    * 3.Save & update "ServiceAppointment" object
    *
    * @Condition - AppointmentType equals to "Video" (Picklist API Name)
    * @Return - void
    */
    @Future(callout=true)
    global static void createNewConnectLink(String recordId) {

        List<ServiceAppointment> saList = [
            SELECT Id, Country__c, SchedStartTime, SchedEndTime, Email, Bambuser_API_Key__c , 
            WorkType.Name, Account.LastName ,Account.FirstName, Link_to_Bambuser_one_to_one_session__c 
            FROM ServiceAppointment WHERE id = :recordId];
        ServiceAppointment sa = saList[0];
        System.debug('saList => ' + saList);
        //Get API key by country
        Bambuser_API_Key_By_Country_c__mdt  apiKeyData = [SELECT MasterLabel, ApiKey__c from Bambuser_API_Key_By_Country_c__mdt WHERE MasterLabel=:sa.Country__c LIMIT 1];
        sa.Bambuser_API_Key__c = apiKeyData.ApiKey__c;

        System.debug('apiKeyData => ' + apiKeyData);
        ConnectLink cl = new ConnectLink();
        DateTime myDateTime1 = sa.SchedStartTime;
        String dateFormatted1 = myDateTime1.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        DateTime myDateTime2 = sa.SchedEndTime;
        String dateFormatted2 = myDateTime2.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        cl.validFrom = (String) dateFormatted1;
        cl.validTo = (String) dateFormatted2;
        cl.firstName = (String) sa.Account.FirstName;
        cl.lastName = (String) sa.Account.LastName;
        cl.email = (String) sa.Email;
        cl.queue =  null;
        cl.externalId =  (String) sa.Id;
        cl.title =  (String) sa.WorkType.Name;
        
        System.debug('ConnectLink => ' + cl);
        String strBody = JSON.serialize(cl);
        
        System.debug('strBody => ' + strBody);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://liveshopping-api.bambuser.com/v1/connect-links');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Token ' + sa.Bambuser_API_Key__c+ '');
        req.setBody(strBody);
        req.setMethod('POST');
        HTTPResponse res = http.send(req);
        
        System.debug('Response => '+ res.getBody());
        String saId = getIdFromResponse(res.getBody());
        sa.Link_to_Bambuser_one_to_one_session__c += saId;
        
        update sa;
    }

    public static String getIdFromResponse(String jsonString) {
        Map<String, String> m = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
        String saId = m.get('id');
        //System.debug(saId);
        return saId;
    }

    /*
    * @Method createVoiceManagement
    * 
    * @Goal: send VoiceCall object (@see class at the buttom) to axialys API
    * Steps:
    * 1.Set the current username & password from Metadata for authentication
    * 2.Send POST request and catch the id on the response
    * 3.Save & update "ServiceAppointment" object
    * 
    * @Condition - AppointmentType equals to "Call" (Picklist API Name)
    * @Return - void
    */
    @Future(callout=true)
    global static void createVoiceManagement(String recordId) {
        System.debug('recordId => ' + recordId);
        // System.debug('ServiceAppointment => ' + sa);
        List<AssignedResource> assignedResources = [SELECT Id, ServiceAppointmentId,ServiceResource.RelatedRecord.Agent_id__c 
                                                        FROM AssignedResource 
                                                        WHERE id = :recordId];
        AssignedResource ar = assignedResources[0]; 
        
        System.debug('AssignedResource => ' + ar + ' RelatedRecordId = ' + ar.ServiceResource.RelatedRecordId + ' Agentt id = ' + ar.ServiceResource.RelatedRecord.Agent_id__c);
        
        List<ServiceAppointment> oneToOneList = [SELECT Phone, Country__c , SchedStartTime, SchedEndTime 
                                                    FROM ServiceAppointment 
                                                    WHERE Id =: ar.ServiceAppointmentId];
        ServiceAppointment sa = oneToOneList[0];

        //List<User> u = [select Agent_id__c from user where  id = :s.RelatedRecordId];
        //User user = u[0];
        //List<ServiceResource> sr = [SELECT Agent_id__c FROM ServiceResource WHERE  id = :ar.ServiceAppointmentId];
        // ServiceResource s = sr[0];
        // System.debug('ServiceResource => ' + s);
        
        //System.debug('sa => ' + sa);
        if(ar.ServiceResource.RelatedRecord.Agent_id__c !=null){
            CountryCode__mdt  countryCodeData = [SELECT MasterLabel, Value__c from CountryCode__mdt WHERE MasterLabel=:sa.Country__c LIMIT 1];
            sa.Country__c = countryCodeData.MasterLabel;

            List<Axialys_API__mdt>  axialysData = [SELECT MasterLabel, Value__c from Axialys_API__mdt];
            
            String username = '';
            String password = '';
            
            for(Axialys_API__mdt o : axialysData) {
                if(o.MasterLabel == 'username') {
                    username = o.Value__c;
                }   
                if(o.MasterLabel == 'password') {
                    password = o.Value__c;
                }
            }

            VoiceCall v = new VoiceCall();
            
            String phoneAfterFormat = getPhoneCountyCode(sa.Phone, countryCodeData.Value__c);
            v.Phone = phoneAfterFormat;
            v.AgentId = ar.ServiceResource.RelatedRecord.Agent_id__c;

            DateTime myDateTime3 = sa.SchedStartTime;
            String dateFormatted3 = myDateTime3.formatGMT('"yyyy-MM-dd\'T\'HH:mm"');
            v.SchedStartTime = dateFormatted3;
            
            DateTime myDateTime4 = sa.SchedEndTime;
            String dateFormatted4 = myDateTime4.formatGMT('"yyyy-MM-dd\'T\'HH:mm"');
            v.SchedEndTime = dateFormatted4;
            
            UtilsHTTP.basicAuthentication(username + ':' + password);
            UtilsHTTP.addHeader('Content-Type', 'application/json');
            String body = '{"dest_number": '+v.Phone+', "id_agent": '+v.AgentId+' , "start_from_date": '+v.SchedStartTime+', "end_before_date": '+v.SchedEndTime+'}';
            System.debug('body => ' + body);
            Httpresponse r = UtilsHTTP.send('https://api.axialys.com/vm/outbound_call', 'POST', body, null);
            String responseStr = r.getBody();
            String response = getIdOutCallFromResponse(responseStr, phoneAfterFormat);  
            sa.Call_Scheduled__c = true;
            
            System.debug('responseStr' + responseStr);
            update sa;
        }


    }

     // 0620121992 --> 33620121992
    public static String getPhoneCountyCode(String phone, String codeCountry) {
      
        String phoneWithoutZero = phone.right(phone.length()-1);
        
        String ph = codeCountry + phoneWithoutZero;
        
        return ph;
    }

    public static String getIdOutCallFromResponse(String jsonString, String phone) {
        Map<String, String> m = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
        String saId = m.get(phone);
        //System.debug('phone' + phone);
        return saId;
    }

    public class ConnectLink {
        @AuraEnabled public String validFrom {get;set;} 
        @AuraEnabled public String validTo {get;set;} 
        @AuraEnabled public String firstName {get;set;} 
        @AuraEnabled public String lastName {get;set;} 
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String queue {get;set;} 
        @AuraEnabled public String externalId {get;set;} 
        @AuraEnabled public String title {get;set;}
    }

    public class VoiceCall {
        @AuraEnabled public String Phone {get;set;} 
        @AuraEnabled public String AgentId {get;set;} 
        @AuraEnabled public String SchedStartTime {get;set;} 
        @AuraEnabled public String SchedEndTime {get;set;} 

    }

}