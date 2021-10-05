public  abstract class UtilsOauth2 {
	 
	public string log					{ get; set; }
	public string retURL				{ get; set; }
	public string customSettingName		{ get; set; }

	public map<string,string> paramsMap { get; set; }	
	public map<string,string> parametersMap { get; set; }	
	
	public string RESPONSE_TYPE			{ get; set; }
	public string CLIENT_ID				{ get; set; }
	public string REDIRECT_URI			{ get; set; }
	public string SCOPE					{ get; set; }
	public string STATE					{ get; set; }
	public string ACCESS_TYPE			{ get; set; }
	public string APPROVAL_PROMPT		{ get; set; }
	public string CLIENT_SECRET 		{ get; set; }
	
	public String authorizationUrl 	{ get; set; }
	public String tokenUrl 			{ get; set; }
    
    public string access_token {get;set;}
	
	public UtilsOauth2 () {
		paramsMap = new map<string,string> ();
	}
	public abstract string refreshToken ();
	public abstract void upsertToken (string resp);
	public abstract void init ();

	public Pagereference initOauth(){
		log+= 'access_token='+access_token;
        /*
        if(access_type!=null && access_type!=''){
         	init();
            return null;
        }
        
		parametersMap  = System.currentPageReference().getParameters();
		if(parametersMap.get('retURL')!=null)
			retURL = parametersMap.get('retURL');
		else if(parametersMap.get('access_token')!=null)
			return null;
		else  if( parametersMap.get('code')!=null )
			return requestToken();
		else 
			return authorization();
*/
        return authorization();
		//return null;
	}	
    //https://accounts.google.com/o/oauth2/auth?
    	//response_type=code&  => V
    	//client_id=266906573614-vt3vmnlqlj0pbeb4ocretv4r1gvbmj2b.apps.googleusercontent.com& => V
    	//scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email& => V
    	//redirect_uri=https%3A%2F%2Foauth.pstmn.io%2Fv1%2Fcallback
	public virtual Pagereference authorization() {
		paramsMap = new Map<string,string> {
				'response_type'     => RESPONSE_TYPE,
				'client_id'  	  	=> CLIENT_ID,
				'redirect_uri' 	    => REDIRECT_URI,
				'scope'     		=> SCOPE
				//'state'     		=> retURL,
				//'access_type'		=> ACCESS_TYPE,
				//'approval_prompt' 	=> APPROVAL_PROMPT
			};
		string url1 = authorizationUrl+'?';
		for(string param : paramsMap.keySet())
			url1 += param+'='+paramsMap.get(param)+'&';		
		return new Pagereference(url1);
	}
	public Pagereference requestToken(){
		string code;
		if(parametersMap.get('code')!=null){
			code = System.currentPageReference().getParameters().get('code');
			log += code;
		}
		if(parametersMap.get('error')!=null){
			String error = parametersMap.get('error');
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Warning,error));
			return null;
		}
		paramsMap = new Map<string,string> {
				'code'     			=> code,
				'client_id'  	  	=> CLIENT_ID,
				'client_secret' 	=> client_secret,
				'redirect_uri'     	=> redirect_uri,
				'grant_type'     	=> 'authorization_code' 
			};
		string body='';
		for(string param : paramsMap.keySet())
			body += param+'='+paramsMap.get(param)+'&';		
        HttpResponse httpResp = UtilsHTTP.send (tokenUrl, 'POST', body, null);
        String resp = httpResp.getBody();
		log += resp;
		upsertToken (resp);
		return null;
		//return new Pagereference(retURL);
	}
	public string refreshToken2(string refresh_token){
		Map<string,string> paramsMap = new Map<string,string> {
				'refresh_token'		=> refresh_token,
				'client_id'  	  	=> CLIENT_ID,
				'client_secret' 	=> client_secret,
				'grant_type'     	=> 'refresh_token'
			};
		string body='';
		for(string param : paramsMap.keySet())
			body += param+'='+paramsMap.get(param)+'&';		
        HttpResponse httpResp = UtilsHTTP.send (tokenUrl, 'POST', body, null);
        String resp = httpResp.getBody();
		log += 'refreshToken2 '+resp;
		return resp;
	}
}