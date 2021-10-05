/**
 * TriggerDispatcher
 * @author BayBridgeDigital (BBD)
 * @date 13/02/2020
 * @version 1.0
 * @description : 
 */

public with sharing class TriggerDispatcher {
    
    //disable all Triggers
    public static Boolean disableTrigger = false;
	public static Integer i=0;
	
    public class TriggerClass{
        ITriggerEntry ite;
    }
    
    public interface ITriggerEntry{
		void prepareData();
		void beforeInsert();
		void beforeUpdate();
		void beforeDelete();
		void afterInsert();
		void afterUpdate();
		void afterDelete();
		void afterUnDelete();
	}

    // Map
    public static Map<String, TriggerClass> iTriggerEntryMAP = new Map<String, TriggerClass>();
    
    // -- Central dispatch Entry --
    public static void entry(String triggerHandlerName)
    {
        if(disableTrigger){
           return;
        }
        i++;
        Type handlerType = Type.forName(triggerHandlerName);
        TriggerClass t;
        ITriggerEntry ite;
                
        // Returns true if this map contains a mapping for the specified key(name of the handler)
        // If there is Map with HandlerName
        if(iTriggerEntryMAP.containsKey(triggerHandlerName)){
            t = iTriggerEntryMAP.get(triggerHandlerName);
            ite = t.ite;
		}
        else{
            t = new TriggerClass();
            t.ite = (ITriggerEntry)handlerType.newInstance();
            ite = t.ite;                      
            t.ite.prepareData();
            // Add value to my Map
            iTriggerEntryMAP.put(triggerHandlerName,t);   
        }          
        execute(ite);
  
    }
    
    
    // -- Execute --
    // "ite" like a Class, such as OpportunitySyncHandler, LeadTriggerHandler, etc
    private static void execute(ITriggerEntry ite){
            if ( Trigger.isBefore && Trigger.isInsert )
                ite.beforeInsert();
            else if ( Trigger.isBefore && Trigger.isUpdate )
                ite.beforeUpdate();
            else if ( Trigger.isBefore && Trigger.isDelete )
                ite.beforeDelete();
            else if ( Trigger.isAfter && Trigger.isInsert )
                ite.afterInsert();
            else if ( Trigger.isAfter && Trigger.isUpdate )
                ite.afterUpdate();
            else if ( Trigger.isAfter && Trigger.isDelete )
                ite.afterDelete();   
    }

}