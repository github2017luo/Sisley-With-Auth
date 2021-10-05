/** UtilsHTTP
 *
 * @author BBD
 * @date 06/12/2014
 * @version 1.0
 * @description 
 */
public class UtilsHTTP {
    //public static HttpRequest  lastReq;
    //public static HttpResponse lastResp;
    public static lastHTTPReqInfo lastReq = new lastHTTPReqInfo();
    public static boolean  afterHTTP = false;
    public class LastHTTPReqInfo{
        public HttpRequest  lastReqInfo;
        public HttpResponse lastRespInfo;
        public Object objInfo;
    }
    static Http ws = new Http ();
    static Httprequest req  = new Httprequest ();

    
    public static void basicAuthentication(string key){
        Blob b = Blob.valueOf(key);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(b);
        UtilsLog.log('Set authorizationHeader : ' + authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
    }
/*
    

    public static void addHeader(string key,string value){
        req.setHeader(key, value);
    }
*/
     public static void bearerAuthentication(string key){
        req.setHeader('Authorization', 'Bearer '+key.trim());
    }

    public static void addHeader(string key,string value){
        req.setHeader(key, value);
    }

    public static HttpResponse send (string endpoint, string method, String body, Blob bodyDoc) {
        UtilsLog.log('UtilsHTTP send');     
                  
        req.setTimeout (120000);
        UtilsLog.log('authorizationHeader : ' + req.getHeader('Authorization'));
        
        UtilsLog.log('endpoint' +endpoint + 'method' +method + 'body' +body + 'bodyDoc' );

        if (null != body){
            req.setBody (body);
            UtilsLog.log('Body : ' + body);
        }
            
        if (null != bodyDoc){
            req.setBodyAsBlob (bodyDoc);
            UtilsLog.log('BodyAsBlob : ' + bodyDoc);
        }
        
        req.setEndpoint (endpoint);
        UtilsLog.log('endpoint  : ' + endpoint);
        
        req.setMethod (method);
        UtilsLog.log('method  : ' + method);
        
        if(!Test.isRunningTest()){
            lastReq.lastReqInfo = req;
            lastReq.lastRespInfo = ws.send (req);
            UtilsLog.log('Resp : ' + lastReq.lastRespInfo);
            UtilsLog.log('Resp Status : ' + lastReq.lastRespInfo.getStatus() );
            UtilsLog.log('Resp Status Code: ' + lastReq.lastRespInfo.getStatusCode() );
            // UtilsLog.log('Resp Body : ' + lastReq.lastRespInfo.getBody() );

            // Dom.Document domDoc = lastReq.lastRespInfo.getBodyDocument();
            // for (Dom.XmlNode elm : domDoc.getRootElement().getChildren()) {
            //     UtilsLog.log('Resp Body-doc : ' + elm );
            // }
        }else {
            lastReq.lastRespInfo = new HttpResponse();
            lastReq.lastRespInfo.setBody('body');
            lastReq.lastRespInfo.setStatusCode(200);
        }
        req  = new Httprequest ();
        UtilsLog.log('');
        afterHTTP = true; 
        if(lastReq !=null  && lastReq.lastRespInfo!=null){
            UtilsLog.log('Body : ' + lastReq.lastRespInfo.getBody ());
            return lastReq.lastRespInfo;
        }
        return null;
    } 
    
    public static string get (string endpoint) {
        HTTPResponse reponseStr = send (endpoint, 'GET', null, null);
        return reponseStr.getBody();
    }
    // public static string getWithParams (string endpoint,string data) {
    //  UtilsLog.log(data);
    //  Map<String, String> params = (Map<String, String>)JSON.deserialize(data, Map<String, String>.class);
    //  string urlParams ='?';
    //  for(String str  : params.keySet()){
    //      urlParams+= '&'+str+'='+params.get(str);
    //  }
    //  urlParams = urlParams.replaceFirst('&', '');
    //  return send (endpoint+urlParams, 'GET', null, null);
    // }
    // public static string post (string endpoint) {
    //     return send (endpoint, 'POST', null, null);
    // }
    public static string postData (string endpoint,string data) {
        HTTPResponse reponseStr = send (endpoint, 'POST', data, null);
        return reponseStr.getBody();
    }
    public static String  getData (string endpoint,string data) {
        HTTPResponse reponseStr = send (endpoint, 'GET', data, null);
        return reponseStr.getBody();
    }
    

}