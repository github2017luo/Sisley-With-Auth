/** 	
 *
 * @author BBD
 * @date 06/12/2018
 * @version 1.0
 * @description 
 */
public class UtilsLog {
	public static string log {get;set;}
	/** log
	 * 
	 * @param object			Object to log
	 * @return					void
	 */
	public static void log(Object str){
    	try{
        	system.debug('\n\n **** '+str+' \n\n');
    	}
    	catch(Exception err){
    		system.debug('\n\n **** LOG FUNCTION: '+err+'\n\n');
    	}
    	try{
    		if(log == null) log='\n\n LOG \n\n';
    		log += String.valueOf(str) + '\n';
    	}catch(Exception err){}
    }
}