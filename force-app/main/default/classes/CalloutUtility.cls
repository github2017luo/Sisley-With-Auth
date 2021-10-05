public class CalloutUtility {
	//method to retrieve information about the Salesforce version
    public static HttpResponse performCallout() {
        HttpRequest req = new HttpRequest();
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
		req.setHeader('Content-Type', 'application/json');
		String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
		system.debug('********domainUrl:'+domainUrl);
		req.setEndpoint(domainUrl+'/services/data/');
		req.setMethod('GET');

		Http h = new Http();
		HttpResponse res = h.send(req);
		system.debug(res.getBody()); 
        return res;
    }
}