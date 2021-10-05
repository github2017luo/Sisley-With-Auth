public class API_Star_RCU_Service extends UtilsOauth2{

    	
    // ========= OAuth2 configuration ================== //
    public API_Star_RCU_Service(){
        log='';
        getAccess_tokenFromCS();
        CLIENT_ID ='266906573614-vt3vmnlqlj0pbeb4ocretv4r1gvbmj2b.apps.googleusercontent.com';
        SCOPE='https://www.googleapis.com/auth/userinfo.email';
        REDIRECT_URI='https://oauth.pstmn.io/v1/callback';/*https://sisley--buildbbd.lightning.force.com/*/
        state='';
        APPROVAL_PROMPT='';
        ACCESS_TYPE='offline';
        RESPONSE_TYPE='code';
        CLIENT_SECRET='7HtJYFFQ1g_BwKpES31jOnE3';
        authorizationUrl= 'https://sisley--buildbbd.lightning.force.com/apex/STAR';//'https://oauth.pstmn.io/v1/callback';
        tokenUrl ='https://oauth2.googleapis.com/token'; 
	}
    public override void init (){}
    public void getAccess_tokenFromCS(){}
    public override string refreshToken (){
        return '';
    }
    public override void upsertToken (string resp){}
   
    /* 
    * Name: getSetting
    * Parameter: API key
    * Return: String 
    * Desc: Get custom meta data for Star API
    */
    public static String getSetting(String key) {
        List<API_Star__mdt> settings = [SELECT Id, MasterLabel, Value__c FROM API_Star__mdt WHERE MasterLabel=:key LIMIT 100];
        if(settings.size() > 0) {
            return settings[0].Value__c;
        }
        return null;
    }
    
    private static String AUTH_TOKEN;
    /* 
    * Name: getAuthToken
    * Return: String 
    * Desc: Get Authentication Token from response header 
    */
    public static string getAuthToken(){
        if(AUTH_TOKEN == null) {
            /*Map<String, string> reqMap = new Map<String, string>();
            reqMap.put('username', getSetting('STAR_API_username'));
            reqMap.put('password', getSetting('STAR_API_password'));
            
            UtilsHTTP.addHeader('Content-Type','application/json');
            String respJSON = UtilsHTTP.send(BASE_URL + '/login', 'POST', JSON.serialize(reqMap), null).getBody();
            if(Test.isRunningTest()){
            respJSON='{"token":"ey","expiryDate":"Tuesday, 25-Aug-2020 19:10:16 CEST"}';
            }
            Map<String, Object> res = (Map<String,Object>) JSON.deserializeUntyped(respJSON);
            System.debug(res);
            UtilsHTTP.log('login token res = '+(String)res.get('token'));
            AUTH_TOKEN = (String)res.get('token');*/
        }
        return AUTH_TOKEN;
    }
    
    
    
    
    
    
    /* 
    * Name: searchAccountsRCU
    * Parameter: Account Id
    * Return: String 
    * Desc: Return customers from RCU DB
    */
    @AuraEnabled
    public static String searchAccountsRCU(Id accountId) {
        // works request => https://app-int-star.azurewebsites.net/v1/Customers/Search/FR?FirstName=test&ResponseType=ID&PageSize=1&PageNumber=1&MaxReturnResult=100&MaxPeriodResult=24&countryCode=FR&version=1
        List<Account> accs = [SELECT Id, ID_RCU__pc, LastName, FirstName, Email_Opt_In__pc, Phone, PersonMobilePhone, PersonEmail FROM Account WHERE Id = :accountId];
        Account acc = accs.size() > 0 ? accs[0] : null;
        
        if(acc == null) {
            System.debug('***ERROR: no account with Id=' + accountId);
            return '{"error": "Incorrect salesforce Id of the Account."}';
        }
        
        String endpoint = getSetting('base_url') + '/Customers/Search?';
        String params = '';
        if(acc.ID_RCU__pc != null) {
            params = 'customerId=' + acc.ID_RCU__pc;
        } else if(acc.FirstName != null && acc.LastName != null) {
            params = 'firstName=' + acc.FirstName + '&'
                + 'lastName=' + acc.LastName;
        } else if(acc.PersonEmail != null) {
            params = 'email=' + acc.PersonEmail;
        } else if(acc.Phone != null) {
            params = 'phone=' + acc.Phone;
        }
        params += String.isEmpty(params) ? '' : '&'
            //+ 'responseType=' + '&'
            //+ 'orderBy=20166082&'
            + 'sort=ASC&'
            + 'pageSize=10&pageNumber=5&maxReturnResult=100&maxPeriodResult=24';
        
        
        return '[{"Row":[{"FieldName":"Id","FieldValue":"B000000120"},{"FieldName":"FirstName","FieldValue":"Guillaume"},{"FieldName":"LastName","FieldValue":"L’herminier"},{"FieldName":"Email","FieldValue":"test@gmail.com"},{"FieldName":"Phone","FieldValue":"0620121992"},{"FieldName":"Birthdate","FieldValue":"11/07/1993"},{"FieldName":"City","FieldValue":"Neuilly-Sur Seine"}]},'
            + '{"Row":[{"FieldName":"Id","FieldValue":"B000000215"},{"FieldName":"FirstName","FieldValue":"Guillaume"},{"FieldName":"LastName","FieldValue":"L’herminier"},{"FieldName":"Email","FieldValue":"test2@gmail.com"},{"FieldName":"Phone","FieldValue":"0620121991"},{"FieldName":"Birthdate","FieldValue":"10/08/1993"},{"FieldName":"City","FieldValue":"Paris"}]}]';
        
        // UtilsHTTP.addHeader('Authorization', 'Bearer ' + getAuthToken());
        // String respJSON = UtilsHTTP.send(endpoint + params, 'GET', null, null).getBody();
        // if(Test.isRunningTest()){
        //     respJSON='{"param":"test response"}'; //TODO: set correct response from API to use during testing
        // }
        
        
        // Map<String, Object> res = (Map<String,Object>) JSON.deserializeUntyped(respJSON);
        // List<Object> lines = (List<Object>)((Map<String, Object>)res.get('Result')).get('Line');
        // //[   
        // //	{    "Row": [     {      "FieldName": "ID",      "FieldValue": "[ID_RCU]"     },     {      "FieldName": "Name",      "FieldValue": "John Doe"     }    ]   },   
        // //	{    "Row": [     {      "FieldName": "voluptate in",      "FieldValue": "aliquip venia"     },     {      "FieldName": "sed aliquip Excepteur",      "FieldValue": "mollit in"     }    ]   }  
        // //]
        // //
        
        // return JSON.serialize(lines);
    }
    
    /* 
    * Name: synchronize
    * Parameter: Account Id, RCU Id (external id)
    * Return: void 
    * Desc: Get data from RCU (by rcuId) and update in Salesforce 
    * step 1: get customer from RCU by id (rcuId)
    * step 2: get Loyalty from RCU by customerId (rcuId)
    * step 3: get sales (orders) from RCU by customerId (rcuId)
    * step 4: update Account (recordId) in salesforce according to mapping
    */
    @AuraEnabled
    public static void synchronize(String accountId, String rcuId) {
        //System.debug('@@@accountId ' + accountId);
        //System.debug('@@@rcuId ' + rcuId);
        
        // ======== API Call to load the responses before doing DML operation ======= //
        String jsonRespFromCustomer = getCustomerById(rcuId);
       // System.debug('@@@jsonRespFromCustomer ' + jsonRespFromCustomer);
        
        //String str = '{"Response":{"Star":{"Technical":{"APIStatusCode":"ut cillum dolore","APIStatusLib":"nisi quis"}},"Sales":[{"Header":{"SalesId":"quis incididunt velit","TransactionUniqueCode":"aliqua pariatur anim","CustomerId":"ad officia adipisicing ea in","StoreId":"mollit proident","SourceTransactionId":"reprehenderit labore non","Date":"Ecom","TypeCode":"Achat","IsGuestOrder":false,"ReturnParentSalesId":"exercitation officia","BcId":"Duis dolor ullamco cillum mollit","InvoiceNumber":"in ","CreationDate":"1983-05-29T10:24:12.790Z","LastUpdateDate":"1944-05-16T17:46:10.093Z","IsDeleted":true,"DeletionDate":"1979-05-16T18:20:40.647Z"},"Amounts":{"CurrencyCode":"USD","TotalAmountWithTax":-45140741.63318851,"TotalAmountWithoutTax":78115867.4641389,"TotalAmountWithTaxAfterDiscount":-65856147.39879726,"TotalAmountWithoutTaxAfterDiscount":65377140.50138703,"TotalAmountWithTaxAfterDiscountAndLoyalty":-51789810.14831416,"TotalAmountWithoutTaxAfterDiscountAndLoyalty":-84523681.6279217,"TotalPaidAmount":-46670945.6396508,"TotalDeliveryFee":57465100.26818764,"DiscountLabel":"consectetur sed voluptate quis"},"LoyaltyData":{"TotalAmountForLoyalty":-5265958.682253033,"LoyaltyPointsUsed":-93538053},"SalesItemLines":[{"SalesItemLinesId":"in dolore","SalesId":"occaecat dolore tempor elit","ProductId":"sint ea ad amet","SKUCode":"Lorem ut eiusmod deserunt","SKUBunde":"in mollit","Quantity":97206630,"LineAmountWithTax":58699863.39124727,"SKUAmountWithTax":-38015663.56236914,"SKUAmountWithoutTax":2227264.360075012,"SKUAmountWithTaxAfterDiscount":53853673.00023368,"SKUAmountWithoutTaxAfterDiscount":85945854.10546273,"SKUAmountWithTaxAfterDiscountAndLoyalty":66143515.31562731,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":80171899.83620954,"LineTransactionTypeCode":"reprehenderit exercitation laborum","ReturnReasonCode":"ad sint anim in","LineLoyaltyPointsUsed":80760519,"CreationDate":"1989-05-17T07:24:13.714Z","LastUpdateDate":"2009-09-20T22:28:30.261Z","IsDeleted":false,"DeletionDate":"1950-03-07T20:59:36.464Z"},{"SalesItemLinesId":"i","SalesId":"dolore quis eu dolore","ProductId":"aliquip in aute mollit","SKUCode":"ipsum cupidatat nostrud","SKUBunde":"adipisicing veniam amet ea ad","Quantity":39357467,"LineAmountWithTax":39927145.73750046,"SKUAmountWithTax":-17041800.486396268,"SKUAmountWithoutTax":17184816.732396245,"SKUAmountWithTaxAfterDiscount":36987315.81590477,"SKUAmountWithoutTaxAfterDiscount":68155407.61394212,"SKUAmountWithTaxAfterDiscountAndLoyalty":-7563536.621025205,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":-44633064.96822925,"LineTransactionTypeCode":"aliquip deserunt irure commodo nostrud","ReturnReasonCode":"commodo fugiat","LineLoyaltyPointsUsed":-38264774,"CreationDate":"1987-09-06T07:36:51.851Z","LastUpdateDate":"1955-12-07T13:59:35.461Z","IsDeleted":false,"DeletionDate":"2018-03-25T07:48:56.626Z"}],"PaymentLines":[{"PaymentLineId":"quis id labore","SalesId":"ut elit","PaymentCurrencyCode":"dolor Lorem amet commodo","PaymentAmount":33963395.36926156,"PaymentTypeCode":"voluptate consectetur","PaymentCustomTypeCode":"Excepteur amet voluptate esse","PaymentCustomTypeLabel":"ipsum cillum magna sint","CreationDate":"1993-05-19T07:59:09.186Z","LastUpdateDate":"1945-07-30T19:59:45.889Z","IsDeleted":true,"DeletionDate":"1965-12-14T06:06:44.969Z"},{"PaymentLineId":"Duis nostrud laborum qui id","SalesId":"id cillum irure","PaymentCurrencyCode":"minim deserunt Ut labore enim","PaymentAmount":98379635.48858905,"PaymentTypeCode":"sed qui","PaymentCustomTypeCode":"Dui","PaymentCustomTypeLabel":"enim","CreationDate":"1971-11-16T21:30:53.217Z","LastUpdateDate":"1984-04-09T12:53:50.770Z","IsDeleted":true,"DeletionDate":"2021-06-19T09:49:44.312Z"}]},{"Header":{"SalesId":"ex","TransactionUniqueCode":"consequat laboris","CustomerId":"culpa proident aliqua Lorem","StoreId":"aliqua eu qui commodo officia","SourceTransactionId":"dolore adiidatat","Date":"Ecom","TypeCode":"Achat","IsGuestOrder":false,"ReturnParentSalesId":"do reprehenderit nostrud","BcId":"ullamco nisi sed magna","InvoiceNumber":"proident nostrud in laborum","CreationDate":"2008-05-16T03:49:14.622Z","LastUpdateDate":"2017-02-22T15:03:07.816Z","IsDeleted":false,"DeletionDate":"1968-02-05T00:04:47.697Z"},"Amounts":{"CurrencyCode":"USD","TotalAmountWithTax":53230069.36218214,"TotalAmountWithoutTax":-5292995.773843676,"TotalAmountWithTaxAfterDiscount":45148573.27579707,"TotalAmountWithoutTaxAfterDiscount":-22768945.066925153,"TotalAmountWithTaxAfterDiscountAndLoyalty":52399993.83081794,"TotalAmountWithoutTaxAfterDiscountAndLoyalty":-23599015.60869582,"TotalPaidAmount":-28218795.623927355,"TotalDeliveryFee":-99084910.98508772,"DiscountLabel":"mollit in"},"LoyaltyData":{"TotalAmountForLoyalty":43544280.50917879,"LoyaltyPointsUsed":-71577749},"SalesItemLines":[{"SalesItemLinesId":"ex","SalesId":"irure ","ProductId":"sed amet laborum nulla","SKUCode":"esse ex tempor dolore","SKUBunde":"dolore ea","Quantity":-25352449,"LineAmountWithTax":80821017.86212274,"SKUAmountWithTax":42278205.6269497,"SKUAmountWithoutTax":5180738.624997303,"SKUAmountWithTaxAfterDiscount":81316350.27370113,"SKUAmountWithoutTaxAfterDiscount":96707496.48098388,"SKUAmountWithTaxAfterDiscountAndLoyalty":80626091.44818422,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":68415368.78287092,"LineTransactionTypeCode":"enim ex quis est Duis","ReturnReasonCode":"magna velit voluptate aute","LineLoyaltyPointsUsed":-85705344,"CreationDate":"1978-08-28T03:31:47.946Z","LastUpdateDate":"1955-08-19T08:01:23.230Z","IsDeleted":false,"DeletionDate":"2005-05-15T16:53:25.320Z"},{"SalesItemLinesId":"cupidatat aute Ut","SalesId":"mollit Duis dolor","ProductId":"ullamco consequat proident","SKUCode":"nostrud Duis adipisicing","SKUBunde":"incididunt dolore","Quantity":11458376,"LineAmountWithTax":-40943787.91210795,"SKUAmountWithTax":-89731171.44776772,"SKUAmountWithoutTax":91424753.72040752,"SKUAmountWithTaxAfterDiscount":25227732.571016356,"SKUAmountWithoutTaxAfterDiscount":19324325.33875659,"SKUAmountWithTaxAfterDiscountAndLoyalty":-67224665.395262,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":-90065962.44114618,"LineTransactionTypeCode":"sint veniam","ReturnReasonCode":"cupidata","LineLoyaltyPointsUsed":86274383,"CreationDate":"1953-11-06T07:42:07.217Z","LastUpdateDate":"1962-02-10T00:38:11.111Z","IsDeleted":false,"DeletionDate":"1975-01-31T06:12:40.228Z"}],"PaymentLines":[{"PaymentLineId":"incididunt Duis","SalesId":"aliqua","PaymentCurrencyCode":"et","PaymentAmount":15324161.69460094,"PaymentTypeCode":"cupidatat consequat velit quis","PaymentCustomTypeCode":"et culpa nulla p","PaymentCustomTypeLabel":"cillum ipsum et","CreationDate":"1987-08-25T22:32:50.134Z","LastUpdateDate":"1959-09-27T01:50:25.124Z","IsDeleted":true,"DeletionDate":"2012-09-18T12:16:57.654Z"},{"PaymentLineId":"laboris minim sed","SalesId":"nostrud reprehenderit laboris dolore in","PaymentCurrencyCode":"irure laborum","PaymentAmount":93455642.17210156,"PaymentTypeCode":"eiusmod id cupidatat","PaymentCustomTypeCode":"tempor sed ex eiusmod eu","PaymentCustomTypeLabel":"qui dolore adipisicing aliquip","CreationDate":"1989-08-08T05:48:50.658Z","LastUpdateDate":"1963-11-08T22:07:43.426Z","IsDeleted":true,"DeletionDate":"1996-10-01T20:10:24.995Z"}]}]}}';
        //String fakeResponse = '{"Response":{"Star":{"Technical":{"APIStatusCode":"string","APIStatusLabel":"string"}},"Sales":[{"Header":{"SalesId":"string","TransactionUniqueCode":"string","CustomerId":"string","StoreId":"string","SourceTransactionId":"string","Date":"2021-09-02T14:53:58.991Z","TypeCode":"string","IsGuestOrder":true,"ReturnParentSalesId":"B000000120","BcId":"string","InvoiceNumber":"string","CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"},"Amounts":{"CurrencyCode":"USD","TotalAmountWithTax":0,"TotalAmountWithoutTax":0,"TotalAmountWithTaxAfterDiscount":0,"TotalAmountWithoutTaxAfterDiscount":0,"TotalAmountWithTaxAfterDiscountAndLoyalty":0,"TotalAmountWithoutTaxAfterDiscountAndLoyalty":0,"TotalPaidAmount":0,"TotalDeliveryFee":0,"DiscountLabel":"string","ShippingCountryCode":"string"},"LoyaltyData":{"TotalAmountForLoyalty":0,"LoyaltyPointsUsed":0},"SalesItemLines":[{"SalesItemLinesId":"string","SalesId":"string","ProductId":"string","SKUCode":"string","SKUBunde":"string","Quantity":0,"LineAmountWithTax":0,"SKUAmountWithTax":0,"SKUAmountWithoutTax":0,"SKUAmountWithTaxAfterDiscount":0,"SKUAmountWithoutTaxAfterDiscount":0,"SKUAmountWithTaxAfterDiscountAndLoyalty":0,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":0,"LineTransactionTypeCode":"string","ReturnReasonCode":"B000000120","LineLoyaltyPointsUsed":0,"CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"}],"PaymentLines":[{"PaymentLineId":"string","SalesId":"string","PaymentCurrencyCode":"USD","PaymentAmount":0,"PaymentTypeCode":"string","PaymentCustomTypeCode":"string","PaymentCustomTypeLabel":"string","CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"}]}]}}';
        String jsonRespFromSales = getCustomerSalesById(rcuId);
        //System.debug('@@@jsonRespFromSales ' + jsonRespFromSales);
        
        //String fakeResponse2 = '{"Response":{"Star":{"Technical":{"APIStatusCode":"string","APIStatusLabel":"string"}},"Loyalty":{"Header":{"AccountId":"string","CustomerId":"string","ProgramId":"string","ProgramCode":"string","ProgramDescription":"string","Date":"2021-09-02T14:53:58.991Z","LastUpdateDate":"2021-09-02T11:37:20.471Z","IsDeleted":true,"DeletionDate":"2021-09-02T11:37:20.471Z"},"LoyaltyProfileCurrentIndicators":{"StatusId":"Nouveau","StatusCode":"ACQ","StatusLabel":"string","AvailablePoints":0,"PendingPoints":0,"NextExpirationDate":"2021-09-02T11:37:20.471Z","NextExpirationPoints":0,"PointsToStatusUpgrade":0,"NextStatusEvaluationDate":"2021-09-02T11:37:20.471Z"},"AccountMovement":[{"AccountMouvementId":"string","AccountId":"string","Date":"2021-09-02T11:37:20.471Z","RuleCode":"string","StatusCode":"ACQ","TypeCode":"string","TotalPoints":0,"PendingPoint":0,"AvailablePoints":0,"UsedPoints":0,"ExpiredPoints":0,"SalesId":"string","EventId":"string","StartValidityDate":"2021-09-02T11:37:20.471Z","EndValidityDate":"2021-09-02T11:37:20.471Z","CreationDate":"2021-09-02T11:37:20.471Z","LastUpdateDate":"2021-09-02T11:37:20.471Z","IsDeleted":true,"DeletionDate":"2021-09-02T11:37:20.471Z"}],"StatusHistory":{"StatusHistoryId":"string","AccountId":"string","StatusId":"Nouveau","PreviousStatusId":"string","StatusStartDate":"2021-09-02T11:37:20.471Z","StatusEndDate":"2021-09-02T11:37:20.471Z","CreationDate":"2021-09-02T11:37:20.471Z","LastUpdateDate":"2021-09-02T11:37:20.471Z","IsDeleted":false,"DeletionDate":"2021-09-02T11:37:20.471Z"}}}}';
        String jsonRespFromLoyals = getLoyaltyById(rcuId); // Should use after Mock tests
       // String jsonRespFromLoyals = fakeResponse2;
        //System.debug('@@@jsonRespFromLoyals ' + jsonRespFromLoyals);// Should use after Mock tests
        
        // =========== Sync Account =============
        
        JsonUtil jsonUtil = new JsonUtil(jsonRespFromCustomer);
        Account accToUpd = new Account(Id=accountId);
        accToUpd.ID_RCU__pc = (String)jsonUtil.getValue('Response|Customer|Header|CustomerId');
        accToUpd.Date_Creation_RCU__pc = toDateTime(jsonUtil.getValue('Response|Customer|Header|CreationDate')).date();
        accToUpd.ID_SFCC__pc = (String)jsonUtil.getValue('Response|Customer|Source|CustomerSourceId');
        accToUpd.Salutation = (String)jsonUtil.getValue('Response|Customer|Identity|CivilityCode');
        accToUpd.LastName = (String)jsonUtil.getValue('Response|Customer|Identity|LastName');
        accToUpd.FirstName  = (String)jsonUtil.getValue('Response|Customer|Identity|FirstName');
        if(jsonUtil.getValue('Response|Customer|Identity|PersonBirthdate') != null) {
            accToUpd.PersonBirthdate  = toDateTime(jsonUtil.getValue('Response|Customer|Identity|PersonBirthdate')).date();    
        }
        
        for(Object obc : (List<Object>)jsonUtil.getValue('Response|Customer|OutboundChannel')) {
            Map<String, Object> obcMap = (Map<String, Object>)obc;
            if(((String)obcMap.get('OutboundChannelTypeCode')) == 'EM_NL') {
                accToUpd.put('PersonEmail', (String)obcMap.get('RawValue'));
            }   
            if(((String)obcMap.get('OutboundChannelTypeCode')) == 'MOBILEPH') {
                accToUpd.put('PersonMobilePhone', (String)obcMap.get('RawValue'));
            }
            if(((String)obcMap.get('OutboundChannelTypeCode')) == 'HOMEPH') {
                accToUpd.put('Phone', (String)obcMap.get('RawValue'));
            }
        }
        
        for(Object a : (List<Object>)jsonUtil.getValue('Response|Customer|Address')) {
            Map<String, Object> aMap = (Map<String, Object>)a;
            if(((String)aMap.get('AdresseTypeCode')) == 'AD1') {
                accToUpd.put('PersonMailingStreet', (String)aMap.get('AddressLine1'));
                accToUpd.put('PersonMailingPostalCode', (String)aMap.get('ZipCode'));
                accToUpd.put('PersonMailingCity', (String)aMap.get('City'));
                accToUpd.put('PersonMailingState', (String)aMap.get('State'));
                accToUpd.put('PersonMailingCountry', (String)aMap.get('CountryCode'));
            }
        }
        
        for(Object con : (List<Object>)jsonUtil.getValue('Response|Customer|Consent')) {
            Map<String, Object> conMap = (Map<String, Object>)con;
            if(((String)conMap.get('ConsentTypeCode')) == 'EM_NL') {
                accToUpd.put('Email_Opt_In__pc', Boolean.valueOf(conMap.get('HasConsent')));
            }   
            if(((String)conMap.get('ConsentTypeCode')) == 'MOBILEPH') {
                accToUpd.put('Mobile_Opt_In__c', Boolean.valueOf(conMap.get('HasConsent')));
            }
            if(((String)conMap.get('ConsentTypeCode')) == 'MOBILEPH') {
                accToUpd.put('SMS_Opt_In__pc', Boolean.valueOf(conMap.get('HasConsent')));
            }
            if(((String)conMap.get('ConsentTypeCode')) == 'HOMEPH') {
                accToUpd.put('Phone_Opt_In__pc', Boolean.valueOf(conMap.get('HasConsent')));
            }      
            if(((String)conMap.get('ConsentTypeCode')) == 'EM_NL') {
                accToUpd.put('Newsletter__pc', Boolean.valueOf(conMap.get('HasConsent')));
            }
            
        }
        
        try {
            update accToUpd;  
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        System.debug('@@@accToUpd ' + accToUpd);
        
        // ========= Sync Order + OrderProduct ========
        List<Order__c> orders = [SELECT ID_RCU__c, ID_SFCC__c, CurrencyIsoCode, AccountID__c, Order_Amount__c, Code_Promo_Utilise__c, Date_d_Achat__c, Animation_Utilisee__c, Lieu_d_Achat__c, Type_achat__c,Return_Parent_OrderID__c, Points_redeemed__c, Total_Amount_With_Tax__c, Total_Amount_With_Tax_After_Discount__c,
                                 (SELECT ID_RCU__c, ID_SFCC__c, CurrencyIsoCode, OrderID__c, OrderID__r.ID_RCU__c, Total_Price__c, Unit_Price__c, Unit_price_after_discount__c, Reference_Produit__c, Product_Name__c, ProduitID__c, EAN__c, Quantite__c  FROM Order_Products__r)  
                                 FROM Order__c WHERE AccountID__c = :accountId];
        
        Set<Id> orderIds = new Set<Id>();
        Map<String, Order__c> ordersByRCU = new Map<String, Order__c>();
        Map<String, Map<String, Order_Product__c>> orderProductsByRCUByOrderRCU = new Map<String, Map<String, Order_Product__c>>();
        
        for(Order__c o : orders) {
            orderIds.add(o.Id);
            ordersByRCU.put(o.ID_RCU__c, o);
            for(Order_Product__c op : o.Order_Products__r) {
                if(orderProductsByRCUByOrderRCU.get(o.ID_RCU__c) == null) {
                    orderProductsByRCUByOrderRCU.put(o.ID_RCU__c, new Map<String, Order_Product__c>());
                }
                orderProductsByRCUByOrderRCU.get(o.ID_RCU__c).put(op.ID_RCU__c, op);
            }
        }
        
        System.debug('@@@jsonRespFromSales' + jsonRespFromSales);
        JSONUtil jsnParseRes = new JSONUtil(jsonRespFromSales);
        if(jsnParseRes.getValue('Status') != null) { 
            System.debug('Error Response => ' + jsnParseRes.getValue('Status'));
            Object statusErr = jsnParseRes.getValue('Status');
            throw new AuraHandledException('An error occurred. status: ' + statusErr);
        } else {
            // mapping for Order & Order Product
            JSONUtil jsnParse = new JSONUtil(jsonRespFromSales);
            List<Object> sales = (List<Object>)jsnParse.getValue('Response|Sales');
            
            Set<String> orderRcuIds = new Set<String>();
            Set<String> productRcuIds = new Set<String>();
            for(Object s : sales) {
                JSONUtil jsnSales = new JSONUtil((Map<String, Object>)s);
                orderRcuIds.add((String)jsnSales.getValue('Header|ReturnParentSalesId'));
                List<Object> salesLines = (List<Object>)jsnSales.getValue('SalesItemLines');
                for(Object sl : salesLines) {
                    JSONUtil jsnSL = new JSONUtil((Map<String, Object>)sl);
                    productRcuIds.add((String)jsnSL.getValue('ProductId'));
                }
            }
            Map<String, Id> orderIdByRcuId = new Map<String, Id>();
            Map<String, Id> productIdByRcuId = new Map<String, Id>();
            for(Order__c o : [SELECT Id, ID_RCU__c FROM Order__c WHERE ID_RCU__c IN :orderRcuIds]) {
                orderIdByRcuId.put(o.ID_RCU__c, o.Id);
            }
            for(Product2 p : [SELECT Id, ID_RCU__c FROM Product2 WHERE ID_RCU__c IN :productRcuIds]) {
                productIdByRcuId.put(p.ID_RCU__c, p.Id);
            }
            
            for(Object s : sales) {
                JSONUtil jsnSales = new JSONUtil((Map<String, Object>)s);
                System.debug('@@@date  ' + (String)jsnSales.getValue('Header|Date')) ;
                String orderRCU = (String)jsnSales.getValue('Header|SalesId');
                Order__c orderToUpsert = ordersByRCU.get(orderRCU);
                if(orderToUpsert == null) {
                    orderToUpsert = new Order__c(AccountID__c=accountId);
                    ordersByRCU.put(orderRCU, orderToUpsert);
                }
                
                orderToUpsert.ID_RCU__c = (String)jsnSales.getValue('Header|SalesId');
                orderToUpsert.ID_SFCC__c = (String)jsnSales.getValue('Header|SourceTransactionId');
                orderToUpsert.Type_achat__c = (String)jsnSales.getValue('Header|TypeCode');
                orderToUpsert.Return_Parent_OrderID__c = orderIdByRcuId.get((String)jsnSales.getValue('Header|ReturnParentSalesId'));
                orderToUpsert.Lieu_d_Achat__c = (String)jsnSales.getValue('Header|Date');
                orderToUpsert.Order_Amount__c = (Decimal)jsnSales.getValue('Amounts|TotalAmountWithoutTaxAfterDiscountAndLoyalty');
                orderToUpsert.Code_Promo_Utilise__c = (String)jsnSales.getValue('Amounts|DiscountLabel');
                orderToUpsert.Total_Amount_With_Tax_After_Discount__c = (Decimal)jsnSales.getValue('Amounts|TotalAmountWithTaxAfterDiscount');
                orderToUpsert.Total_Amount_With_Tax__c = (Decimal)jsnSales.getValue('Amounts|TotalAmountWithTax');
                orderToUpsert.CurrencyIsoCode = (String)jsnSales.getValue('Amounts|CurrencyCode');
                
                System.debug('@@@orderToUpsert ' + orderToUpsert);
                List<Object> salesLines = (List<Object>)jsnSales.getValue('SalesItemLines');
                for(Object sl : salesLines) {
                    JSONUtil jsnSL = new JSONUtil((Map<String, Object>)sl);
                    if(orderProductsByRCUByOrderRCU.get(orderRCU) == null) {
                        orderProductsByRCUByOrderRCU.put(orderRCU, new Map<String, Order_Product__c>());
                    }
                    String orderProdRCU = (String)jsnSL.getValue('SalesItemLinesId');
                    Order_Product__c orderProdToUpsert = orderProductsByRCUByOrderRCU.get(orderRCU).get(orderProdRCU);
                    if(orderProdToUpsert == null) {
                        orderProdToUpsert = new Order_Product__c();
                        orderProductsByRCUByOrderRCU.get(orderRCU).put(orderProdRCU, orderProdToUpsert);
                    }
                    orderProdToUpsert.ID_RCU__c = orderProdRCU;
                    orderProdToUpsert.ProduitID__c  = productIdByRcuId.get((String)jsnSL.getValue('ProductId'));
                    orderProdToUpsert.CurrencyIsoCode = (String)jsnSales.getValue('Amounts|CurrencyCode');
                    orderProdToUpsert.Total_Price__c = (Decimal)jsnSL.getValue('LineAmountWithTax');
                    orderProdToUpsert.Unit_Price__c = (Decimal)jsnSL.getValue('LineAmountWithTax');
                    orderProdToUpsert.Total_Price__c = (Decimal)jsnSL.getValue('SKUAmountWithTax');
                    orderProdToUpsert.Unit_Price_After_Discount__c = (Decimal)jsnSL.getValue('SKUAmountWithTaxAfterDiscount');
                    orderProdToUpsert.Quantite__c = (Decimal)jsnSL.getValue('Quantity');
                    System.debug('@@@orderProdToUpsert ' + orderProdToUpsert);
                }
            }
            System.debug('@@@ordersByRCU.values() ' + ordersByRCU.values());
            try {
                upsert ordersByRCU.values();
            }
            catch (Exception ex) {
                throw new aurahandledexception(ex.getMessage());
            }
            
            
            List<Order_Product__c> orderProductsToUpsert = new List<Order_Product__c>();
            for(String key : orderProductsByRCUByOrderRCU.keySet()) {
                Order__c order = ordersByRCU.get(key);
                Map<String, Order_Product__c> orderProductsByRCU = orderProductsByRCUByOrderRCU.get(key);
                if(order != null && orderProductsByRCU != null) {
                    for(String ordProdKey : orderProductsByRCU.keySet()) {
                        orderProductsByRCU.get(ordProdKey).OrderID__c = order.Id;
                        orderProductsToUpsert.add(orderProductsByRCU.get(ordProdKey));
                    }
                } else {
                    System.debug('@@@ orderRCU='+key+', order='+order+', orderProductsByRCU='+orderProductsByRCU);
                }
            }
            
            try {
                upsert orderProductsToUpsert;
            }
            catch (Exception ex) {
                throw new aurahandledexception(ex.getMessage());
            }
            
            
            // ========== Sync Loyalty + LoyaltyMovement =============
            List<Loyalty__c> loyalties = [SELECT ID_RCU__c, Date_Statut_Membre__c, Nb_Points_Acquis__c,Nb_Points_En_Cours__c,Prochaine_date_expiration__c,Points_arrivant_expiration__c,Points_manquants_prochain_statut__c,
                                          (SELECT LoyaltyID__c, AccountMouvementId__c,Date__c,RuleCode__c,StatusCode__c, TotalPoints__c ,PendingPoint__c,
                                           AvailablePoints__c, UsedPoints__c, ExpiredPoints__c, StartValidityDate__c, EndValidityDate__c, isDeleted__c, DeletionDate__c FROM Loyalty_Movements__r) 
                                          FROM Loyalty__c where Client__c = :accountId];
            
            Set<Id> loyaltyIds = new Set<Id>();
            Map<String, Loyalty__c> loyaltiesByRCU = new Map<String, Loyalty__c>();
            Map<String, List<Loyalty_Movement__c>> loyaltyMovmentsByLoyaltyRCU = new Map<String, List<Loyalty_Movement__c>>();
            
            for(Loyalty__c l : loyalties) {
                loyaltyIds.add(l.Id);
                loyaltiesByRCU.put(l.ID_RCU__c, l);
                for(Loyalty_Movement__c lm : l.Loyalty_Movements__r) {
                    if(loyaltyMovmentsByLoyaltyRCU.get(l.ID_RCU__c) == null) {
                        loyaltyMovmentsByLoyaltyRCU.put(l.ID_RCU__c, new List<Loyalty_Movement__c>());
                    }
                }
            }
            JSONUtil jsnParseRes2 = new JSONUtil(jsonRespFromLoyals);
            if(jsnParseRes.getValue('Status') != null) { 
                System.debug('Error Response => ' + jsnParseRes.getValue('Status'));
                Object statusErr = jsnParseRes.getValue('Status');
                throw new AuraHandledException('An error occurred. status: ' + statusErr);
            } else {
                // mapping for Loyalty & Loyalty Movment
                JSONUtil jsnParse2 = new JSONUtil(jsonRespFromLoyals);
                Map<String,Object> loyal = (Map<String,Object>)jsnParseRes2.getValue('Response|Loyalty');
                
                Set<String> orderForLmRcuIds = new Set<String>();
                
                JSONUtil jsnLoyals = new JSONUtil((Map<String, Object>)loyal);
                List<Object> loyalMovments = (List<Object>)jsnParseRes2.getValue('Response|Loyalty|AccountMovement');
                for(Object lm : loyalMovments) {
                    JSONUtil jsnLM = new JSONUtil((Map<String, Object>)lm);  
                    orderForLmRcuIds.add((String)jsnLM.getValue('SalesId'));
                }
                
                for(Order__c o : [SELECT Id, ID_RCU__c FROM Order__c WHERE ID_RCU__c IN :orderForLmRcuIds]) {
                    orderIdByRcuId.put(o.ID_RCU__c, o.Id);
                }
                
                //Loyalty parsing
                String loyalRCU = (String)jsnLoyals.getValue('Header|ProgramId');
                Loyalty__c loyaltyToUpsert = loyaltiesByRCU.get(loyalRCU);
                if(loyaltyToUpsert == null) {
                    loyaltyToUpsert = new Loyalty__c(Client__c=accountId);
                    loyaltiesByRcu.put(loyalRCU, loyaltyToUpsert);
                }
                
                loyalRCU = (String)jsnLoyals.getValue('Header|ProgramId');
                loyaltyToUpsert.ID_RCU__c = (String)jsnLoyals.getValue('Header|CustomerId');
                loyaltyToUpsert.Name = (String)jsnLoyals.getValue('Header|ProgramId');
                loyaltyToUpsert.Statut__c = (String)jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|StatusId');
                loyaltyToUpsert.Nb_Points_Acquis__c = (Decimal)jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|AvailablePoints');
                loyaltyToUpsert.Nb_Points_En_Cours__c = (Decimal)jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|PendingPoints');
                loyaltyToUpsert.Prochaine_date_expiration__c = toDateTime(jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|NextExpirationDate')).date();
                loyaltyToUpsert.Points_arrivant_expiration__c = (Decimal)jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|NextExpirationPoints');
                loyaltyToUpsert.Points_manquants_prochain_statut__c = (Decimal)jsnLoyals.getValue('LoyaltyProfileCurrentIndicators|PointsToStatusUpgrade');
                
                for(Object lm : loyalMovments) {
                    JSONUtil jsnLM = new JSONUtil((Map<String, Object>)lm);
                    if(loyaltyMovmentsByLoyaltyRCU.get(loyalRCU) == null) {
                        loyaltyMovmentsByLoyaltyRCU.put(loyalRCU, new List<Loyalty_Movement__c>());
                    }
                    String loyaltyMovmentRCU = (String)jsnLM.getValue('AccountId');
                    
                    Loyalty_Movement__c loyalMovmentToUpsert = new Loyalty_Movement__c();
                    loyaltyMovmentsByLoyaltyRCU.get(loyalRCU).add(loyalMovmentToUpsert);
                    
                    loyalMovmentToUpsert.AccountMouvementId__c = (String)jsnLM.getValue('AccountMouvementId');
                    loyalMovmentToUpsert.Date__c = toDateTime(jsnLM.getValue('Date')).date();
                    loyalMovmentToUpsert.RuleCode__c = (String)jsnLM.getValue('RuleCode');
                    loyalMovmentToUpsert.StatusCode__c = (String)jsnLM.getValue('StatusCode');   
                    loyalMovmentToUpsert.TotalPoints__c = (Decimal)jsnLM.getValue('TotalPoints');  
                    loyalMovmentToUpsert.PendingPoint__c = (Decimal)jsnLM.getValue('PendingPoint');   
                    loyalMovmentToUpsert.AvailablePoints__c = (Decimal)jsnLM.getValue('AvailablePoints');  
                    loyalMovmentToUpsert.UsedPoints__c = (Decimal)jsnLM.getValue('UsedPoints');         
                    loyalMovmentToUpsert.ExpiredPoints__c = (Decimal)jsnLM.getValue('ExpiredPoints');   
                    loyalMovmentToUpsert.OrderID__c = orderIdByRcuId.get((String)jsnLM.getValue('SalesId'));        
                    loyalMovmentToUpsert.StartValidityDate__c = toDateTime(jsnLM.getValue('StartValidityDate')).date();  
                    loyalMovmentToUpsert.EndValidityDate__c = toDateTime(jsnLM.getValue('EndValidityDate')).date();    
                    if(jsnLM.getValue('isDeleted') != null) {
                        loyalMovmentToUpsert.isDeleted__c = Boolean.valueOf(jsnLM.getValue('isDeleted'));    
                    }
                    loyalMovmentToUpsert.DeletionDate__c = toDateTime(jsnLM.getValue('DeletionDate')).date();    
                }
                    
                try {
                    upsert loyaltiesByRCU.values();
                }
                catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
                
                
                List<Loyalty_Movement__c> loyalMovmentsToUpsert = new List<Loyalty_Movement__c>();
                for(String key : loyaltyMovmentsByLoyaltyRCU.keySet()) {
                    Loyalty__c loyalty = loyaltiesByRCU.get(key);
                    List<Loyalty_Movement__c> loyaltyMovmentsByRCU = loyaltyMovmentsByLoyaltyRCU.get(key);
                    if(loyalty != null && loyaltyMovmentsByRCU != null) {
                        for(Loyalty_Movement__c loyMov : loyaltyMovmentsByRCU) {
                            loyMov.LoyaltyID__c = loyalty.Id;
                            loyalMovmentsToUpsert.add(loyMov);
                        }
                    } else {
                        System.debug('@@@ orderRCU='+key+', order='+loyalty+', orderProductsByRCU='+loyaltyMovmentsByRCU);
                    }
                }
                try {
                    upsert loyalMovmentsToUpsert;
                }
                catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
                
            }           
        }
    }
     
    public static String getCustomerById(String rcuId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-int-star.azurewebsites.net/v1/Customers/'+rcuId+'');
        request.setMethod('GET');
        try {            
            if(Test.isRunningTest()){
                // Mock response
                return '{"Response":{"Star":{"Technical":{"APIStatusCode":"string","APIStatusLabel":"string"}},"Sales":[{"Header":{"SalesId":"string","TransactionUniqueCode":"string","CustomerId":"string","StoreId":"string","SourceTransactionId":"string","Date":"2021-09-02T14:53:58.991Z","TypeCode":"string","IsGuestOrder":true,"ReturnParentSalesId":"B000000120","BcId":"string","InvoiceNumber":"string","CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"},"Amounts":{"CurrencyCode":"USD","TotalAmountWithTax":0,"TotalAmountWithoutTax":0,"TotalAmountWithTaxAfterDiscount":0,"TotalAmountWithoutTaxAfterDiscount":0,"TotalAmountWithTaxAfterDiscountAndLoyalty":0,"TotalAmountWithoutTaxAfterDiscountAndLoyalty":0,"TotalPaidAmount":0,"TotalDeliveryFee":0,"DiscountLabel":"string","ShippingCountryCode":"string"},"LoyaltyData":{"TotalAmountForLoyalty":0,"LoyaltyPointsUsed":0},"SalesItemLines":[{"SalesItemLinesId":"string","SalesId":"string","ProductId":"string","SKUCode":"string","SKUBunde":"string","Quantity":0,"LineAmountWithTax":0,"SKUAmountWithTax":0,"SKUAmountWithoutTax":0,"SKUAmountWithTaxAfterDiscount":0,"SKUAmountWithoutTaxAfterDiscount":0,"SKUAmountWithTaxAfterDiscountAndLoyalty":0,"SKUAmountWithoutTaxAfterDiscountAndLoyalty":0,"LineTransactionTypeCode":"string","ReturnReasonCode":"B000000120","LineLoyaltyPointsUsed":0,"CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"}],"PaymentLines":[{"PaymentLineId":"string","SalesId":"string","PaymentCurrencyCode":"USD","PaymentAmount":0,"PaymentTypeCode":"string","PaymentCustomTypeCode":"string","PaymentCustomTypeLabel":"string","CreationDate":"2021-09-02T12:39:31.222Z","LastUpdateDate":"2021-09-02T12:39:31.222Z","IsDeleted":true,"DeletionDate":"2021-09-02T12:39:31.222Z"}]}]}}';
            } 
            HttpResponse response = http.send(request);
            return response.getBody();
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
  
    public static String getCustomerSalesById(String rcuId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-int-star.azurewebsites.net/v1/Customers/'+rcuId+'');
        request.setMethod('GET'); 
        try {
            
            if(Test.isRunningTest()){
                // Mock response
                return '{"Response":{"Star":{"Technical":{"APIStatusCode":"commodo laborum ut","APIStatusLib":"sint occaecat irure consectetur"}},"Customer":{"Header":{"CustomerId":"esse dolor culpa","CreationDate":"1978-04-28T06:53:50.719Z","LastUpdateDate":"2011-10-11T11:59:27.979Z","LastUpdateSourceCode":"culpa deserunt quis","IsDeleted":true,"DeletionDate":"2003-04-14T21:47:08.588Z","DeleteSourceCode":"elit labore sunt ut"},"Anonymization":{"AnomyzationAgentSourceId":"quis in aute","AnonymizationDate":"2012-05-07T12:43:02.450Z","AnonymizationReasonCode":"laboris nulla dolor nisi adipisicing","AnonymizationSourceCode":"est Excepteur tempor pariatur Ut"},"Master_Classification":{"BrandCode":"amet","CountryCode":"dolo","CreationChannelCode":"minim veniam fugiat consectetur","OrigineChaineCode":"nulla velit aute","EnrollmentDate":"1969-06-15T23:02:27.679Z","CustomerStatusCode":"consequat est minim reprehenderit"},"Identity":{"GenderCode":"id deserunt officia laboris","CivilityCode":"anim elit ex et","FirstName":"sunt Excepteur aute","FirstName2nbAlphabet":"in commodo ad","LastName":"veniam dolor tempor aliqua ","LastName2andAlphabet":"minim tempor","SecondLastName":"non nos","BirthDate":"1991-09-04T04:28:48.912Z","IsBirthDateYearValid":true,"NationalityCode":"dolor sint eu dolor","IdentityLastUpdateDate":"1988-05-06T21:17:01.943Z","IdentityLastUpdateSourceCode":"Lorem ut sit exercitati"},"Preference":{"PreferedLanguageCode":"magna","PreferedCommChannelCode":"dolor dolore dolore","PreferedStoreCode":"laborum Duis dolore ipsum","PreferedBCCode":"sint labore exercitation et cillum"},"OutBoundChannel":[{"OutboundChannelId":"B000000120","CustomerId":"B000000120","OutboundChannelTypeCode":"EM_NL","RawValue":"Duis aute","NormalizedValue":"nisi Excepteur laboris cupidata","QualityProcessingCode":"nulla elit tempor laborum","QualityStatutCode":"Ut reprehenderit","BounceReason":"do dolore cupidatat","BounceStatutCode":"sint qui","IsUsable":false,"CreationDate":"2007-04-27T04:33:31.688Z","LastUpdateDate":"1958-07-27T16:28:19.164Z","LastUpdateSourceCode":"occaecat et dolor","IsDeleted":false,"DeletionDate":"1997-09-05T14:36:24.320Z","DeleteSourceCode":"est labore"},{"OutboundChannelId":"B000000120","CustomerId":"B000000120","OutboundChannelTypeCode":"MOBILEPH","RawValue":"dolor","NormalizedValue":"adipisicing","QualityProcessingCode":"eu voluptate deserunt aute","QualityStatutCode":"dolore ea nisi id","BounceReason":"laborum labore exercitation","BounceStatutCode":"cupidatat","IsUsable":true,"CreationDate":"1998-08-16T10:40:57.989Z","LastUpdateDate":"1952-02-25T23:53:53.401Z","LastUpdateSourceCode":"sit magna et nulla","IsDeleted":true,"DeletionDate":"2004-10-21T13:16:41.481Z","DeleteSourceCode":"sed mollit "}],"Address":[{"AddressId":"consequat velit","CustomerId":"nostrud irure","AdresseTypeCode":"AD1","AddressLine1":"ipsum mollit a","AddressLine2":"in ea","AddressLine3":"do aliquip occaecat","AddressLine4":"ut commodo","ZipCode":"ea cupidatat id","City":"id eiusmod minim quis tempor","State":"eu cons","Company":"amet","CountryCode":"FR","QualityProcessingCode":"cupidatat nulla Lorem consequat ipsum","QualityStatutCode":"ad consectetur dolor sit a","BounceCount":"Excepteur","BounceStatutCode":"dolore sint eiusmod in non","IsUsable":false,"CreationDate":"1975-07-13T09:32:58.765Z","LastUpdateDate":"2021-06-20T23:32:59.491Z","LastUpdateSourceCode":"eiusmod non ","IsDeleted":true,"DeletionDate":"1961-03-20T13:19:53.638Z","DeleteSourceCode":"sed ut"},{"AddressId":"consequat","CustomerId":"reprehenderit","AdresseTypeCode":"laborum ea elit aute","AddressLine1":"in cupidatat magna","AddressLine2":"nisi","AddressLine3":"sint do enim non","AddressLine4":"pariatur incididunt","ZipCode":"mag","City":"tempor","State":"proident officia","Company":"non velit anim dolore aliqua","CountryCode":"nulla esse minim","QualityProcessingCode":"id","QualityStatutCode":"ut qui adipisicing proident","BounceCount":"consectetur deserunt cillum laboris veniam","BounceStatutCode":"sed enim consectetur dolor","IsUsable":false,"CreationDate":"1972-06-22T00:46:42.470Z","LastUpdateDate":"1992-11-02T17:41:39.015Z","LastUpdateSourceCode":"minim in","IsDeleted":false,"DeletionDate":"2019-06-30T03:48:59.872Z","DeleteSourceCode":"occaecat tempor enim esse"}],"Consent":[{"ConsentId":"B000000120","CustomerId":"B000000120","ConsentTypeCode":"EM_NL","HasConsent":"irure tempor","ConsentDenialReason":"anim consectetur ea","SignatureImage":"ullamco occaecat","CreationDate":"1961-11-14T14:08:02.821Z","LastUpdateDate":"1976-04-07T05:17:00.022Z","LastUpdateSourceCode":"in ipsum non"},{"ConsentId":"B000000120","CustomerId":"B000000120","ConsentTypeCode":"MOBILEPH","HasConsent":"ullamco in mollit nostrud","ConsentDenialReason":"eu exercitation","SignatureImage":"dolore nulla incididunt","CreationDate":"1994-01-06T07:37:26.398Z","LastUpdateDate":"1949-03-21T20:21:21.032Z","LastUpdateSourceCode":"ad dolor adipisicing et"}],"Subscription":[{"SubscriptionId":"exercitation nostrud","CustomerId":"Ex","SubscriptionTypeCode":"ut non","SubscriptionStatusCode":"cillum quis ipsum","SubscriptionDate":"1966-04-04T16:56:51.396Z","UnsubscriptionDate":"2016-03-06T05:38:29.522Z","UnsubscriptionReasonCode":"dolor ipsum","CreationDate":"1968-03-18T06:40:02.927Z","LastUpdateDate":"1984-04-23T09:04:21.935Z","LastUpdateSourceCode":"id sint elit"},{"SubscriptionId":"exercitation et tempor","CustomerId":"dolor occaecat adipisicing voluptate dolor","SubscriptionTypeCode":"nisi adipisicing Ut laborum velit","SubscriptionStatusCode":"esse velit exercitation aliquip ","SubscriptionDate":"1956-10-06T17:46:24.438Z","UnsubscriptionDate":"1967-11-06T02:17:11.984Z","UnsubscriptionReasonCode":"minim ut in","CreationDate":"1994-08-03T08:39:45.772Z","LastUpdateDate":"1950-12-11T17:34:25.480Z","LastUpdateSourceCode":"cillum Excepteur Lorem occaecat"}],"Event":[{"EventId":"qui ut in","CustomerId":"aliqua","EventTypeCode":"do nisi elit Excepteur","EventDate":"1961-02-08T20:58:24.164Z","CustomerSourceId":"eiusmod dolore","TouchPointCode":"sunt officia eu commodo","CreationBCCode":"sunt consectetur eu velit","CreationDeviceCode":"consectetur exercitation officia","CreationDate":"2000-07-02T02:07:05.459Z","EventData":[{"EventDataId":"est","EventId":"pariatur sint","Key":"enim aliqua eu","Value":"exercitation do f"},{"EventDataId":"fugiat","EventId":"fugiat quis ut irure","Key":"labore et tempor","Value":"quis nulla ipsum cupidatat"}]},{"EventId":"voluptate","CustomerId":"pariatur ex labo","EventTypeCode":"ullamco mollit tempor reprehenderi","EventDate":"2005-02-20T18:23:26.133Z","CustomerSourceId":"est nisi an","TouchPointCode":"magna amet Duis","CreationBCCode":"laborum dolor magna","CreationDeviceCode":"ea dolore","CreationDate":"2019-07-15T15:27:02.846Z","EventData":[{"EventDataId":"aliquip occaecat magna","EventId":"Excepteur velit incididunt d","Key":"reprehenderit officia","Value":"eiusmod enim"},{"EventDataId":"aliquip ex enim Lorem sint","EventId":"minim sunt cupidatat incididunt culpa","Key":"esse laborum elit do","Value":"amet Ut ad ipsum"}]}],"ExtendedProfile":[{"ExtendedProfileId":"nulla et in labore","CustomerId":"sint laborum irure dolor","ExtendedProfileTypeCode":"irure in","CreationDate":"1960-06-14T05:52:58.501Z","LastUpdateDate":"1978-09-10T17:55:52.480Z","LastUpdateSourceCode":"laborum amet dolore qui","ExtendedProfileData":[{"ExtendedProfileDataId":"dolore in","ExtendedProfileId":"tempor","Key":"sint esse aliqua ad","Value":"Lorem officia"},{"ExtendedProfileDataId":"nostrud qui","ExtendedProfileId":"sit mollit in pariatur","Key":"commodo fugiat","Value":"magna in officia"}]},{"ExtendedProfileId":"dolore pariatur ut sed","CustomerId":"dolor do voluptate","ExtendedProfileTypeCode":"est esse cillum dolore dolor","CreationDate":"1985-07-22T05:15:12.486Z","LastUpdateDate":"1946-05-12T03:34:35.890Z","LastUpdateSourceCode":"mollit cillu","ExtendedProfileData":[{"ExtendedProfileDataId":"ipsum dolor culpa","ExtendedProfileId":"ex occaecat in nulla","Key":"magna","Value":"ea proid"},{"ExtendedProfileDataId":"sint in","ExtendedProfileId":"ipsum aliquip pariatur minim","Key":"do adipisicing in","Value":"aute sed"}]}],"Source":[{"SourceId":"nulla consequat ullamco","SourceRecordId":"laboris","CustomerId":"laboris anim laborum","CustomerSourceId":"sed fu","SourceCode":"proident in adipisicing mollit","SourceOriginLabel":"cillum qui","SourceBrandCode":"sed elit nisi","SourceCountryCode":"ex in laboris sint","SourceChainCode":"officia","SourceStoreCode":"anim","SourceBCCode":"nostrud ex in mollit dolore","SourceStatusCode":"consectetu","CreationDate":"1971-02-08T11:50:36.441Z","LastUpdateDate":"1947-01-10T22:43:55.030Z"},{"SourceId":"dolor dolo","SourceRecordId":"laboris tempor","CustomerId":"Ut labore","CustomerSourceId":"dolore laborum","SourceCode":"sed ea","SourceOriginLabel":"sit adipisicing est","SourceBrandCode":"enim sed Lorem exercitation Duis","SourceCountryCode":"Lorem","SourceChainCode":"minim","SourceStoreCode":"labore occaecat officia ","SourceBCCode":"aute cupidatat ","SourceStatusCode":"reprehenderit","CreationDate":"1969-11-24T20:29:12.145Z","LastUpdateDate":"1996-02-28T13:05:26.476Z"}]}}}';
            }
            HttpResponse response = http.send(request);
            return response.getBody();
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
     
    public static String getLoyaltyById(String rcuId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-int-star.azurewebsites.net/v1/Customers/'+rcuId+'');
        request.setMethod('GET');
        try {
            if(Test.isRunningTest()){
                // Mock response
                return '{"Response":{"Star":{"Technical":{"APIStatusCode":"commodo laborum ut","APIStatusLib":"sint occaecat irure consectetur"}},"Customer":{"Header":{"CustomerId":"esse dolor culpa","CreationDate":"1978-04-28T06:53:50.719Z","LastUpdateDate":"2011-10-11T11:59:27.979Z","LastUpdateSourceCode":"culpa deserunt quis","IsDeleted":true,"DeletionDate":"2003-04-14T21:47:08.588Z","DeleteSourceCode":"elit labore sunt ut"},"Anonymization":{"AnomyzationAgentSourceId":"quis in aute","AnonymizationDate":"2012-05-07T12:43:02.450Z","AnonymizationReasonCode":"laboris nulla dolor nisi adipisicing","AnonymizationSourceCode":"est Excepteur tempor pariatur Ut"},"Master_Classification":{"BrandCode":"amet","CountryCode":"dolo","CreationChannelCode":"minim veniam fugiat consectetur","OrigineChaineCode":"nulla velit aute","EnrollmentDate":"1969-06-15T23:02:27.679Z","CustomerStatusCode":"consequat est minim reprehenderit"},"Identity":{"GenderCode":"id deserunt officia laboris","CivilityCode":"anim elit ex et","FirstName":"sunt Excepteur aute","FirstName2nbAlphabet":"in commodo ad","LastName":"veniam dolor tempor aliqua ","LastName2andAlphabet":"minim tempor","SecondLastName":"non nos","BirthDate":"1991-09-04T04:28:48.912Z","IsBirthDateYearValid":true,"NationalityCode":"dolor sint eu dolor","IdentityLastUpdateDate":"1988-05-06T21:17:01.943Z","IdentityLastUpdateSourceCode":"Lorem ut sit exercitati"},"Preference":{"PreferedLanguageCode":"magna","PreferedCommChannelCode":"dolor dolore dolore","PreferedStoreCode":"laborum Duis dolore ipsum","PreferedBCCode":"sint labore exercitation et cillum"},"OutBoundChannel":[{"OutboundChannelId":"B000000120","CustomerId":"B000000120","OutboundChannelTypeCode":"EM_NL","RawValue":"Duis aute","NormalizedValue":"nisi Excepteur laboris cupidata","QualityProcessingCode":"nulla elit tempor laborum","QualityStatutCode":"Ut reprehenderit","BounceReason":"do dolore cupidatat","BounceStatutCode":"sint qui","IsUsable":false,"CreationDate":"2007-04-27T04:33:31.688Z","LastUpdateDate":"1958-07-27T16:28:19.164Z","LastUpdateSourceCode":"occaecat et dolor","IsDeleted":false,"DeletionDate":"1997-09-05T14:36:24.320Z","DeleteSourceCode":"est labore"},{"OutboundChannelId":"B000000120","CustomerId":"B000000120","OutboundChannelTypeCode":"MOBILEPH","RawValue":"dolor","NormalizedValue":"adipisicing","QualityProcessingCode":"eu voluptate deserunt aute","QualityStatutCode":"dolore ea nisi id","BounceReason":"laborum labore exercitation","BounceStatutCode":"cupidatat","IsUsable":true,"CreationDate":"1998-08-16T10:40:57.989Z","LastUpdateDate":"1952-02-25T23:53:53.401Z","LastUpdateSourceCode":"sit magna et nulla","IsDeleted":true,"DeletionDate":"2004-10-21T13:16:41.481Z","DeleteSourceCode":"sed mollit "}],"Address":[{"AddressId":"consequat velit","CustomerId":"nostrud irure","AdresseTypeCode":"AD1","AddressLine1":"ipsum mollit a","AddressLine2":"in ea","AddressLine3":"do aliquip occaecat","AddressLine4":"ut commodo","ZipCode":"ea cupidatat id","City":"id eiusmod minim quis tempor","State":"eu cons","Company":"amet","CountryCode":"FR","QualityProcessingCode":"cupidatat nulla Lorem consequat ipsum","QualityStatutCode":"ad consectetur dolor sit a","BounceCount":"Excepteur","BounceStatutCode":"dolore sint eiusmod in non","IsUsable":false,"CreationDate":"1975-07-13T09:32:58.765Z","LastUpdateDate":"2021-06-20T23:32:59.491Z","LastUpdateSourceCode":"eiusmod non ","IsDeleted":true,"DeletionDate":"1961-03-20T13:19:53.638Z","DeleteSourceCode":"sed ut"},{"AddressId":"consequat","CustomerId":"reprehenderit","AdresseTypeCode":"laborum ea elit aute","AddressLine1":"in cupidatat magna","AddressLine2":"nisi","AddressLine3":"sint do enim non","AddressLine4":"pariatur incididunt","ZipCode":"mag","City":"tempor","State":"proident officia","Company":"non velit anim dolore aliqua","CountryCode":"nulla esse minim","QualityProcessingCode":"id","QualityStatutCode":"ut qui adipisicing proident","BounceCount":"consectetur deserunt cillum laboris veniam","BounceStatutCode":"sed enim consectetur dolor","IsUsable":false,"CreationDate":"1972-06-22T00:46:42.470Z","LastUpdateDate":"1992-11-02T17:41:39.015Z","LastUpdateSourceCode":"minim in","IsDeleted":false,"DeletionDate":"2019-06-30T03:48:59.872Z","DeleteSourceCode":"occaecat tempor enim esse"}],"Consent":[{"ConsentId":"B000000120","CustomerId":"B000000120","ConsentTypeCode":"EM_NL","HasConsent":"irure tempor","ConsentDenialReason":"anim consectetur ea","SignatureImage":"ullamco occaecat","CreationDate":"1961-11-14T14:08:02.821Z","LastUpdateDate":"1976-04-07T05:17:00.022Z","LastUpdateSourceCode":"in ipsum non"},{"ConsentId":"B000000120","CustomerId":"B000000120","ConsentTypeCode":"MOBILEPH","HasConsent":"ullamco in mollit nostrud","ConsentDenialReason":"eu exercitation","SignatureImage":"dolore nulla incididunt","CreationDate":"1994-01-06T07:37:26.398Z","LastUpdateDate":"1949-03-21T20:21:21.032Z","LastUpdateSourceCode":"ad dolor adipisicing et"}],"Subscription":[{"SubscriptionId":"exercitation nostrud","CustomerId":"Ex","SubscriptionTypeCode":"ut non","SubscriptionStatusCode":"cillum quis ipsum","SubscriptionDate":"1966-04-04T16:56:51.396Z","UnsubscriptionDate":"2016-03-06T05:38:29.522Z","UnsubscriptionReasonCode":"dolor ipsum","CreationDate":"1968-03-18T06:40:02.927Z","LastUpdateDate":"1984-04-23T09:04:21.935Z","LastUpdateSourceCode":"id sint elit"},{"SubscriptionId":"exercitation et tempor","CustomerId":"dolor occaecat adipisicing voluptate dolor","SubscriptionTypeCode":"nisi adipisicing Ut laborum velit","SubscriptionStatusCode":"esse velit exercitation aliquip ","SubscriptionDate":"1956-10-06T17:46:24.438Z","UnsubscriptionDate":"1967-11-06T02:17:11.984Z","UnsubscriptionReasonCode":"minim ut in","CreationDate":"1994-08-03T08:39:45.772Z","LastUpdateDate":"1950-12-11T17:34:25.480Z","LastUpdateSourceCode":"cillum Excepteur Lorem occaecat"}],"Event":[{"EventId":"qui ut in","CustomerId":"aliqua","EventTypeCode":"do nisi elit Excepteur","EventDate":"1961-02-08T20:58:24.164Z","CustomerSourceId":"eiusmod dolore","TouchPointCode":"sunt officia eu commodo","CreationBCCode":"sunt consectetur eu velit","CreationDeviceCode":"consectetur exercitation officia","CreationDate":"2000-07-02T02:07:05.459Z","EventData":[{"EventDataId":"est","EventId":"pariatur sint","Key":"enim aliqua eu","Value":"exercitation do f"},{"EventDataId":"fugiat","EventId":"fugiat quis ut irure","Key":"labore et tempor","Value":"quis nulla ipsum cupidatat"}]},{"EventId":"voluptate","CustomerId":"pariatur ex labo","EventTypeCode":"ullamco mollit tempor reprehenderi","EventDate":"2005-02-20T18:23:26.133Z","CustomerSourceId":"est nisi an","TouchPointCode":"magna amet Duis","CreationBCCode":"laborum dolor magna","CreationDeviceCode":"ea dolore","CreationDate":"2019-07-15T15:27:02.846Z","EventData":[{"EventDataId":"aliquip occaecat magna","EventId":"Excepteur velit incididunt d","Key":"reprehenderit officia","Value":"eiusmod enim"},{"EventDataId":"aliquip ex enim Lorem sint","EventId":"minim sunt cupidatat incididunt culpa","Key":"esse laborum elit do","Value":"amet Ut ad ipsum"}]}],"ExtendedProfile":[{"ExtendedProfileId":"nulla et in labore","CustomerId":"sint laborum irure dolor","ExtendedProfileTypeCode":"irure in","CreationDate":"1960-06-14T05:52:58.501Z","LastUpdateDate":"1978-09-10T17:55:52.480Z","LastUpdateSourceCode":"laborum amet dolore qui","ExtendedProfileData":[{"ExtendedProfileDataId":"dolore in","ExtendedProfileId":"tempor","Key":"sint esse aliqua ad","Value":"Lorem officia"},{"ExtendedProfileDataId":"nostrud qui","ExtendedProfileId":"sit mollit in pariatur","Key":"commodo fugiat","Value":"magna in officia"}]},{"ExtendedProfileId":"dolore pariatur ut sed","CustomerId":"dolor do voluptate","ExtendedProfileTypeCode":"est esse cillum dolore dolor","CreationDate":"1985-07-22T05:15:12.486Z","LastUpdateDate":"1946-05-12T03:34:35.890Z","LastUpdateSourceCode":"mollit cillu","ExtendedProfileData":[{"ExtendedProfileDataId":"ipsum dolor culpa","ExtendedProfileId":"ex occaecat in nulla","Key":"magna","Value":"ea proid"},{"ExtendedProfileDataId":"sint in","ExtendedProfileId":"ipsum aliquip pariatur minim","Key":"do adipisicing in","Value":"aute sed"}]}],"Source":[{"SourceId":"nulla consequat ullamco","SourceRecordId":"laboris","CustomerId":"laboris anim laborum","CustomerSourceId":"sed fu","SourceCode":"proident in adipisicing mollit","SourceOriginLabel":"cillum qui","SourceBrandCode":"sed elit nisi","SourceCountryCode":"ex in laboris sint","SourceChainCode":"officia","SourceStoreCode":"anim","SourceBCCode":"nostrud ex in mollit dolore","SourceStatusCode":"consectetu","CreationDate":"1971-02-08T11:50:36.441Z","LastUpdateDate":"1947-01-10T22:43:55.030Z"},{"SourceId":"dolor dolo","SourceRecordId":"laboris tempor","CustomerId":"Ut labore","CustomerSourceId":"dolore laborum","SourceCode":"sed ea","SourceOriginLabel":"sit adipisicing est","SourceBrandCode":"enim sed Lorem exercitation Duis","SourceCountryCode":"Lorem","SourceChainCode":"minim","SourceStoreCode":"labore occaecat officia ","SourceBCCode":"aute cupidatat ","SourceStatusCode":"reprehenderit","CreationDate":"1969-11-24T20:29:12.145Z","LastUpdateDate":"1996-02-28T13:05:26.476Z"}]}}}';
            } 
            HttpResponse response = http.send(request);
            return response.getBody();
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    
    /* 
    * Name: createCustomer
    * Parameter: Account Id
    * Return: void 
    * Desc: Send HTTP POST request to create a new customer on RCU (db)
    */
    @AuraEnabled
    public static void createCustomer(String recordId) {
        
        // create account in RCU from account on Salseforce
        
        
        String customerId;
        Account acc = [
            SELECT Id, ID_RCU__pc, ID_SFCC__pc, RecordTypeId, Date_Creation_RCU__pc, Salutation, PersonTitle, Mobile_Opt_In__c
            ,LastName, FirstName, PersonBirthdate, PersonMobilePhone, PersonEmail, PersonMailingStreet, phone, ID_STAR__pc
            , PersonMailingPostalCode, PersonMailingCity,  Email_Opt_In__pc, PersonMailingState, PersonMailingCountry 
            ,Phone_Opt_In__pc, SMS_Opt_In__pc, Whatsapp_Opt_In__pc, Newsletter__pc, Date_Premier_Achat__pc, Date_Dernier_Achat__pc
            ,Preoccupation_Soin__pc, Preoccupation_Maquillage__pc, Univers_Parfum__pc, Preoccupation_Hair_Rituel__pc, Type_de_Peau__pc, Lieu_habituel_d_achat__pc
            From Account Where Id =:recordId];
        
        JSONUtil jsnGen = new JSONUtil();
        
        jsnGen.putValue('Customer|Header', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|MasterClassification', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|Preference', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|Identity|CivilityCode', acc.Salutation);
        jsnGen.putValue('Customer|Identity|FirstName', acc.FirstName);
        jsnGen.putValue('Customer|Identity|LastName', acc.LastName);
        jsnGen.putValue('Customer|Identity|BirthDate', acc.PersonBirthdate);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Email');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.PersonEmail);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Phone');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.Phone);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Mobile');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.PersonMobilePhone);
        jsnGen.putValue('Customer|Address|[*]|AdresseTypeCode', 'AD1');
        jsnGen.putValue('Customer|Address|[#]|ZipCode', acc.PersonMailingStreet);
        jsnGen.putValue('Customer|Address|[#]|AddressLine1', acc.PersonMailingPostalCode);
        jsnGen.putValue('Customer|Address|[#]|City', acc.PersonMailingCity);
        jsnGen.putValue('Customer|Address|[#]|CountryCode', acc.PersonMailingCountry);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'EM_xx');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Email_Opt_In__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'EM_NL');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Newsletter__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'MOBILEPH');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.SMS_Opt_In__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'MOBILEPH');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Phone_Opt_In__pc);
        jsnGen.putValue('Customer|Source|[*]|CreationDate', acc.Date_Creation_RCU__pc );
        jsnGen.putValue('Customer|Source|[#]|CustomerSourceId', acc.ID_SFCC__pc );
        
        String jsonStr = jsnGen.buildJson();
        System.debug('*** ' + jsonStr);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-int-star.azurewebsites.net/v1/Customers');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonStr);
        HttpResponse response = http.send(request);
        Map<String, Object> res = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('@@@res ' + res);
        JSONUtil jsnParseRes = new JSONUtil(res);
       	customerId = (String)jsnParseRes.getValue('Response|Customer|Header|CustomerId');
        acc.ID_RCU__pc = customerId;
        
        try {
            update acc;     
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
                
    }
   
    /* 
    * Name: updateCustomer
    * Parameter: Account Id
    * Return: void 
    * Desc: Send HTTP PUT request to update exist customer on RCU (db)
    */
    
    @AuraEnabled    
    public static void updateCustomer(String recordId) {
        Account acc = [
            SELECT Id, ID_RCU__pc, ID_SFCC__pc, RecordTypeId, Date_Creation_RCU__pc, Salutation, PersonTitle, Mobile_Opt_In__c
            ,LastName, FirstName, PersonBirthdate, PersonMobilePhone, PersonEmail, PersonMailingStreet, phone, ID_STAR__pc
            , PersonMailingPostalCode, PersonMailingCity,  Email_Opt_In__pc, PersonMailingState, PersonMailingCountry 
            ,Phone_Opt_In__pc, SMS_Opt_In__pc, Whatsapp_Opt_In__pc, Newsletter__pc, Date_Premier_Achat__pc, Date_Dernier_Achat__pc
            ,Preoccupation_Soin__pc, Preoccupation_Maquillage__pc, Univers_Parfum__pc, Preoccupation_Hair_Rituel__pc, Type_de_Peau__pc, Lieu_habituel_d_achat__pc
            From Account Where Id =:recordId];
        
        
        JSONUtil jsnGen = new JSONUtil();
        
        jsnGen.putValue('Customer|Header|CustomerId', acc.ID_RCU__pc);
        jsnGen.putValue('Customer|Header', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|MasterClassification', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|Preference', JSONUtil.EMPTY_OBJECT);
        jsnGen.putValue('Customer|Identity|CivilityCode', acc.Salutation);
        jsnGen.putValue('Customer|Identity|FirstName', acc.FirstName);
        jsnGen.putValue('Customer|Identity|LastName', acc.LastName);
        jsnGen.putValue('Customer|Identity|BirthDate', acc.PersonBirthdate);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Email');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.PersonEmail);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Phone');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.Phone);
        jsnGen.putValue('Customer|OutBoundChannel|[*]|OutboundChannelTypeCode', 'Mobile');
        jsnGen.putValue('Customer|OutBoundChannel|[#]|RawValue', acc.PersonMobilePhone);
        jsnGen.putValue('Customer|Address|[*]|AdresseTypeCode', 'AD1');
        jsnGen.putValue('Customer|Address|[#]|ZipCode', acc.PersonMailingStreet);
        jsnGen.putValue('Customer|Address|[#]|AddressLine1', acc.PersonMailingPostalCode);
        jsnGen.putValue('Customer|Address|[#]|City', acc.PersonMailingCity);
        jsnGen.putValue('Customer|Address|[#]|CountryCode', acc.PersonMailingCountry);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'EM_xx');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Email_Opt_In__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'EM_NL');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Newsletter__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'MOBILEPH');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.SMS_Opt_In__pc);
        jsnGen.putValue('Customer|Consent|[*]|ConsentTypeCode', 'MOBILEPH');
        jsnGen.putValue('Customer|Consent|[#]|HasConsent', acc.Phone_Opt_In__pc);
        jsnGen.putValue('Customer|Source|[*]|CreationDate', acc.Date_Creation_RCU__pc );
        jsnGen.putValue('Customer|Source|[#]|CustomerSourceId', acc.ID_SFCC__pc );
        
        String jsonStr = jsnGen.buildJson();
        System.debug('*** ' + jsonStr);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://app-int-star.azurewebsites.net/v1/Customers/'+acc.ID_RCU__pc+'');
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonStr);
        HttpResponse response = http.send(request);
        Map<String, Object> res = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('@@@res ' + res);
        
        
        try {
            update acc;     
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /* 
    * Name: getProduct
    * Parameter: rcuId
    * Return: String response
    * Desc: Send HTTP GET request to get product from RCU (db)
    */
    
    @AuraEnabled    
    public static String getProduct(String rcuId) {

            String exampleRes = '{"Response":{"Star":{"Technical":{"APIStatusCode":"cillum qui magna es","APIStatusLib":"ipsum ut"}},"Product":{"Header":{"ProductId":"qui elit ea cillum","PimCode":"aliqua do irure","SKU":"enim commodo ex","Ean":"aute","CreationDate":"1969-04-19T22:47:11.888Z","LastUpdateDate":"2005-10-26T16:30:50.344Z","LastUpdateSourceCode":"laboris commodo"},"ProductInfo":{"ProductId":"est incididunt","MasterProductId":"ullamco esse aliqu","ProductName":"ut incididunt officia est elit","ProductType":"dolore non ullamco","Status":"velit nostrud anim","SapSoaAvailabilityDate":"ex commodo","SoaAvailabilityDateUpdate":"velit quis in","FieldAvailabilityDate":"cillum laborum ullamco sunt","Weight":12,"Volume":45,"Capacity":87,"Axe":"culpa nisi mollit","Category":"nostrud","SubCategory":"qui ad incididunt","AssociatedItemClassificationCode":"commodo reprehenderit ut anim voluptate"},"Translations":[{"ProductId":"ipsu","LanguageCode":"dolore quis commodo","Key":"laborum dolore","Value":"exercitation esse enim"},{"ProductId":"commodo consectetur","LanguageCode":"enim","Key":"deserunt minim eu","Value":"nisi incididunt"}],"Prices":[{"ProductId":"magna consectetur","StoreId":"ex magna aute","Price":"magna","IsVAT":true},{"ProductId":"amet cupidatat dolore","StoreId":"in laborum amet pariatur","Price":"adipisicing e","IsVAT":false}],"ExtendedAttributes":[{"ExtendedAttributesDataId":"ut","ProductId":"velit elit minim","Key":"Excepteur nulla ","Value":"est laborum Excepteur"},{"ExtendedAttributesDataId":"esse labore voluptat","ProductId":"molli","Key":"eu deserunt","Value":"anim"}],"Medias":[{"MediaDataId":"amet ipsum esse","ProductId":"laborum veniam","Key":"consectetur cupidatat qui","Value":"magna "},{"MediaDataId":"magna occaecat","ProductId":"culpa cupidatat commodo","Key":"elit ad","Value":"laboris nulla laborum"}],"ProductCrossSell":[{"ProductId":"exercitation sunt in","RelatedProductID":"non pariatur ull"},{"ProductId":"dolore adipisicing","RelatedProductID":"officia nulla eiusmod id"}],"ProductCatalog":[{"CatalogId":"laborum reprehenderit est","ProductId":"sed velit ex","CountryCode":"dolor sed","IsVisibleInStore":true,"IsVisibleInEcommerce":false,"IsVisibleInMaisonSisley":false},{"CatalogId":"voluptate sunt","ProductId":"occaecat commodo ut in","CountryCode":"deserunt ea","IsVisibleInStore":false,"IsVisibleInEcommerce":true,"IsVisibleInMaisonSisley":true}]}}}';
            JSONUtil jsnParseRes = new JSONUtil(exampleRes);
            //String id = jsnParseRes.getValue(rcuIdAndProductsMap.keySet());
            Product2 prodToSend = new Product2(ID_RCU__c = rcuId);
            //prodToSend.ID_RCU__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductId');
            prodToSend.SKU__c = (String)jsnParseRes.getValue('Response|Product|Header|SKU');
            prodToSend.EAN__c = (String)jsnParseRes.getValue('Response|Product|Header|Ean');
            prodToSend.Name = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductName');
            prodToSend.ProductType__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductType');
            prodToSend.AssociatedItemClassificationCode__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|AssociatedItemClassificationCode');
            prodToSend.Weight__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Weight');
            prodToSend.Volume__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Volume');
            prodToSend.Capacity__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Capacity');
            prodToSend.Axe__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|Axe');
            prodToSend.Category__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|Category');
            prodToSend.SapSoaAvailabilityDate__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|SapSoaAvailabilityDate');
            //System.debug('prodToSend => ' + prodToSend);
            List<Object> medias = (List<Object>) jsnParseRes.getValue('Response|Product|Medias');        
            for(Object m : medias) {
                JSONUtil jsnMedia = new JSONUtil((Map<String, Object>)m);
                //prodToSend.MP = (String)jsnMedia.getValue('Key');
                prodToSend.Media_URL__c = (String)jsnMedia.getValue('Value');
                System.debug('value ' + jsnMedia.getValue('Value'));
            }
            
            System.debug('prodToSend => ' + prodToSend);
            
            String prodStr = JSON.serialize(prodToSend);
            return prodStr;    
     
        
    }
         
    /* 
    * Name: updateProduct
    * Parameter: productId
    * Return: void
    * Desc: Update Product on Salesforce according to the response from getProduct method
    */
    
    @AuraEnabled    
    public static void updateProduct(String rcuId) {
        List<Product2> prod = [SELECT ID_RCU__c FROM Product2 WHERE ID_RCU__c = :rcuId];
        
            String exampleResonse = '{"Response":{"Star":{"Technical":{"APIStatusCode":"cillum qui magna es","APIStatusLib":"ipsum ut"}},"Product":{"Header":{"ProductId":"qui elit ea cillum","PimCode":"aliqua do irure","SKU":"enim commodo ex","Ean":"aute","CreationDate":"1969-04-19T22:47:11.888Z","LastUpdateDate":"2005-10-26T16:30:50.344Z","LastUpdateSourceCode":"laboris commodo"},"ProductInfo":{"ProductId":"est incididunt","MasterProductId":"ullamco esse aliqu","ProductName":"ut incididunt officia est elit","ProductType":"dolore non ullamco","Status":"velit nostrud anim","SapSoaAvailabilityDate":"ex commodo","SoaAvailabilityDateUpdate":"velit quis in","FieldAvailabilityDate":"cillum laborum ullamco sunt","Weight":12,"Volume":45,"Capacity":87,"Axe":"culpa nisi mollit","Category":"nostrud","SubCategory":"qui ad incididunt","AssociatedItemClassificationCode":"commodo reprehenderit ut anim voluptate"},"Translations":[{"ProductId":"ipsu","LanguageCode":"dolore quis commodo","Key":"laborum dolore","Value":"exercitation esse enim"},{"ProductId":"commodo consectetur","LanguageCode":"enim","Key":"deserunt minim eu","Value":"nisi incididunt"}],"Prices":[{"ProductId":"magna consectetur","StoreId":"ex magna aute","Price":"magna","IsVAT":true},{"ProductId":"amet cupidatat dolore","StoreId":"in laborum amet pariatur","Price":"adipisicing e","IsVAT":false}],"ExtendedAttributes":[{"ExtendedAttributesDataId":"ut","ProductId":"velit elit minim","Key":"Excepteur nulla ","Value":"est laborum Excepteur"},{"ExtendedAttributesDataId":"esse labore voluptat","ProductId":"molli","Key":"eu deserunt","Value":"anim"}],"Medias":[{"MediaDataId":"amet ipsum esse","ProductId":"laborum veniam","Key":"consectetur cupidatat qui","Value":"magna "},{"MediaDataId":"magna occaecat","ProductId":"culpa cupidatat commodo","Key":"elit ad","Value":"laboris nulla laborum"}],"ProductCrossSell":[{"ProductId":"exercitation sunt in","RelatedProductID":"non pariatur ull"},{"ProductId":"dolore adipisicing","RelatedProductID":"officia nulla eiusmod id"}],"ProductCatalog":[{"CatalogId":"laborum reprehenderit est","ProductId":"sed velit ex","CountryCode":"dolor sed","IsVisibleInStore":true,"IsVisibleInEcommerce":false,"IsVisibleInMaisonSisley":false},{"CatalogId":"voluptate sunt","ProductId":"occaecat commodo ut in","CountryCode":"deserunt ea","IsVisibleInStore":false,"IsVisibleInEcommerce":true,"IsVisibleInMaisonSisley":true}]}}}';
            JSONUtil jsnParseRes = new JSONUtil(exampleResonse);
            
            Product2 prodToUpdate = new Product2(ID_RCU__c = prod[0].ID_RCU__c);
            //prodToUpdate.ID_RCU__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductId');
            prodToUpdate.SKU__c = (String)jsnParseRes.getValue('Response|Product|Header|SKU');
            prodToUpdate.EAN__c = (String)jsnParseRes.getValue('Response|Product|Header|Ean');
            prodToUpdate.Name = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductName');
            prodToUpdate.ProductType__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|ProductType');
            prodToUpdate.AssociatedItemClassificationCode__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|AssociatedItemClassificationCode');
            prodToUpdate.Weight__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Weight');
            prodToUpdate.Volume__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Volume');
            prodToUpdate.Capacity__c = (Decimal)jsnParseRes.getValue('Response|Product|ProductInfo|Capacity');
            prodToUpdate.Axe__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|Axe');
            prodToUpdate.Category__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|Category');
            prodToUpdate.SapSoaAvailabilityDate__c = (String)jsnParseRes.getValue('Response|Product|ProductInfo|SapSoaAvailabilityDate');
            //System.debug('prodToUpdate => ' + prodToUpdate);
            List<Object> medias = (List<Object>) jsnParseRes.getValue('Response|Product|Medias');        
            for(Object m : medias) {
                JSONUtil jsnMedia = new JSONUtil((Map<String, Object>)m);
                //prodToUpdate.MP = (String)jsnMedia.getValue('Key');
                prodToUpdate.Media_URL__c = (String)jsnMedia.getValue('Value');
                System.debug('value ' + jsnMedia.getValue('Value'));
            }
            
            System.debug('prodToUpdate => ' + prodToUpdate);
            
            try {
                update prodToUpdate; 
            }
            catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }
    
    	
    private static DateTime toDateTime(Object val) {
        try {
            return (DateTime)JSON.deserialize((String)val, DateTime.class);
        } catch(Exception ex) {
            System.debug('error: ' + ex.getMessage());
            //throw new AuraHandledException(ex.getMessage());
            
        } 
        return null;
    }
    

}