public class JSONUtil {
    
    public static final Map<String, Object> EMPTY_OBJECT = new Map<String, Object>();
    public static final List<Object> EMPTY_ARRAY = new List<Object>();
   
    private static final Integer LAST_INDEX_CODE = -2; //#
    private static final Integer ADD_NEW_CODE = -3; //*

    private Map<String, Object> jsonMap = new Map<String, Object>();
   
    public JSONUtil() {}
   
    public JSONUtil(Map<String, Object> jsonMap) {
        this.jsonMap = jsonMap;
    }
   
    public JSONUtil(String jsonInitString) {
        jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInitString);
    }
   
    public String buildJson() {
        return JSON.serialize(jsonMap);
    }
   
    private void addVal(Map<String, Object> json_Map, String key, Object value) {
        json_Map.put(key, value);
    }
   
    private Integer parseKeyIndex(String key) {
        if(key.contains('[')) {
            key = key.trim();
            key = key.substring(1, key.length() - 1);
            if(key == '#') return LAST_INDEX_CODE; //last
            if(key == '*') return ADD_NEW_CODE; //add new
            return Integer.valueOf(key);
        }
        return null;
    }
   
    private Integer parseKeyIndexGet(String key) {
        if(key.contains('[')) {
            key = key.trim();
            key = key.substring(1, key.length() - 1);
            if(key == '#') return 0;
            if(key == '*') return 0;
            return Integer.valueOf(key);
        }
        return null;
    }

    public void putValue(String key, Object value) {
        if(key.contains('|')) {
            Object containerToPutNewVal = this.jsonMap;
            List<String> splittedKey = key.split('\\|');
            for(Integer i = 0; i < splittedKey.size(); i++) {
                String subKey = splittedKey[i];
                Integer arrIndex = parseKeyIndex(subKey);
               
                if(i + 1 == splittedKey.size()) { //if the current key is the last one
                    if(arrIndex == null) { //if the current subKey is key - just put in to the map
                        Map<String, Object> mapToPutNewVal = (Map<String, Object>)containerToPutNewVal;
                        addVal(mapToPutNewVal, subKey, value);
                    } else { //if the current subKey is index - add it to the list or rewrite if exists (OutOfBounds exception if more than current size of the array)
                        List<Object> listToPutNewVal = (List<Object>)containerToPutNewVal;
                        if(listToPutNewVal.size() == arrIndex || arrIndex == ADD_NEW_CODE || (arrIndex == LAST_INDEX_CODE && listToPutNewVal.size() == 0)) {
                            listToPutNewVal.add(value);
                        }
                        arrIndex = (arrIndex == LAST_INDEX_CODE || arrIndex == ADD_NEW_CODE) ? listToPutNewVal.size() - 1 : arrIndex;
                        listToPutNewVal[arrIndex] = value;
                    }
                   
                } else {
                    Integer nextArrIndex = parseKeyIndex(splittedKey[i + 1]);

                    if(arrIndex == null) { //if the current subKey is key - use map
                        Map<String, Object> mapToPutNewVal = (Map<String, Object>)containerToPutNewVal;
                        if(mapToPutNewVal.get(subKey) == null) {
                            if(nextArrIndex == null) { //if the next subKey is key - put map
                                mapToPutNewVal.put(subKey, new Map<String, Object>());
                            } else { //if the next subKey is index - put list
                                mapToPutNewVal.put(subKey, new List<Object>());
                            }
                        }
                        containerToPutNewVal = mapToPutNewVal.get(subKey);
                    } else {//if the current subKey is index - use list
                        List<Object> listToPutNewVal = (List<Object>)containerToPutNewVal;
                        if(listToPutNewVal.size() == arrIndex || arrIndex == ADD_NEW_CODE || (arrIndex == LAST_INDEX_CODE && listToPutNewVal.size() == 0)) {
                            if(nextArrIndex == null) { //if the next subKey is key - put map
                                listToPutNewVal.add(new Map<String, Object>());
                            } else { //if the next subKey is index - put list
                                listToPutNewVal.add(new List<Object>());
                            }
                        }
                        arrIndex = (arrIndex == LAST_INDEX_CODE || arrIndex == ADD_NEW_CODE) ? listToPutNewVal.size() - 1 : arrIndex;
                        containerToPutNewVal = listToPutNewVal[arrIndex];
                    }
                }
            }
        } else {
            addVal(this.jsonMap, key, value);
        }
    }
   
    public Object getValue(String key) {
        if(key.contains('|')) {
            Object containerOfLastVal = this.jsonMap;
            List<String> splittedKey = key.split('\\|');
            for(Integer i = 0; i < splittedKey.size(); i++) {
                String subKey = splittedKey[i];
                Integer arrIndex = parseKeyIndexGet(subKey);
               
                if(i + 1 == splittedKey.size()) { //if the current key is the last one
                    if(containerOfLastVal == null) {
                        return null;
                    }
                    if(arrIndex == null) { //if the current subKey is key - just put in to the map
                        if(!(containerOfLastVal instanceof Map<String, Object>)) {
                            return null;
                        }
                        Map<String, Object> mapOfLastVal = (Map<String, Object>)containerOfLastVal;
                        return mapOfLastVal.get(subKey);
                    } else { //if the current subKey is index - add it to the list or rewrite if exists (OutOfBounds exception if more than current size of the array)
                        if(!(containerOfLastVal instanceof List<Object>)) {
                            return null;
                        }
                        List<Object> listOfLastVal = (List<Object>)containerOfLastVal;
                        if(listOfLastVal != null && listOfLastVal.size() > arrIndex) {
                            return listOfLastVal[arrIndex];
                        }
                        return null;
                    }
                   
                } else {                    
                    Integer nextArrIndex = parseKeyIndexGet(splittedKey[i + 1]);

                    if(arrIndex == null) { //if the current subKey is key - use map
                        if(!(containerOfLastVal instanceof Map<String, Object>)) {
                            return null;
                        }
                        Map<String, Object> mapOfLastVal = (Map<String, Object>)containerOfLastVal;
                        containerOfLastVal = mapOfLastVal.get(subKey);
                        if(containerOfLastVal == null) {
                            return null;
                        }
                    } else {//if the current subKey is index - use list
                        if(!(containerOfLastVal instanceof List<Object>)) {
                            return null;
                        }
                        List<Object> listOfLastVal = (List<Object>)containerOfLastVal;
                        if(arrIndex >= listOfLastVal.size()) {
                            return null;
                        }
                        containerOfLastVal = listOfLastVal[arrIndex];
                    }
                }
            }
        } else {
            return this.jsonMap.get(key);
        }
       
        return null;
    }
   
    public Boolean isArray(String key) {
        Object node = getValue(key);
        Boolean result = false;
        try {
            String strNode = JSON.serializePretty(node);
            result = strNode.substring(0, 1).equals('[');
        } catch(Exception e) {
        result = false;
        }
        return result;
    }
   
    public Boolean isObject(String key) {
        Object node = getValue(key);
        Boolean result;
        try {
            String strNode = JSON.serializePretty(node);
            result = strNode.substring(0, 1).equals('{');
        } catch(Exception e) {
        result = false;
        }
        return result;
    }
   
    public Boolean isValue(String key) {
        return !isArray(key) && !isObject(key);
    }
   
    public List<String> getKeySet(String key) {
        List<String> keySet = new List<String>();
        if(isObject(key)) {
            Map<String, Object> nodeMap = (Map<String, Object>)getValue(key);
            keySet.addAll(nodeMap.keySet());
        }
        return keySet;        
    }
   
    public List<String> getKeySet() {
        List<String> keySet = new List<String>();
        if(jsonMap != null) {
            keySet.addAll(jsonMap.keySet());
        }
        return keySet;
    }
    /*
    public static void test() {
        JSONUtil jsnGen = new JSONUtil();
        jsnGen.putValue('hostId', 'test host ID');
        jsnGen.putValue('customerContact|name', 'test customer Name');
        jsnGen.putValue('pickup|address|floor', 1);
        jsnGen.putValue('pickup|fromTime', System.now());
        jsnGen.putValue('firstStop|packages|[*]|barcode', '0001');
        jsnGen.putValue('firstStop|packages|[*]|barcode', '0002');
        System.debug('*** ' + jsnGen.buildJson());
        jsnGen.putValue('firstStop|packages|[#]|barcode', '0003');
        jsnGen.putValue('firstStop|packages|[#]|barcodeX', '0003X');
        jsnGen.putValue('firstStop|testKey|[0]|[0]', 'Test 1');
        jsnGen.putValue('firstStop|testKey|[1]|[0]', 'Test 2');
        jsnGen.putValue('firstStop|testKey|[0]|[#]', 'Test 11');
        String jsonStr = jsnGen.buildJson();
        System.debug('*** ' + jsonStr);
       
        System.debug('$$$ isArray: ' + jsnGen.isArray('firstStop|packages'));
        System.debug('$$$ isObject: ' + jsnGen.isObject('firstStop|packages'));
        System.debug('$$$ isArray: ' + jsnGen.isArray('firstStop'));
        System.debug('$$$ isObject: ' + jsnGen.isObject('firstStop'));
       
        JSONUtil jsnGen2 = new JSONUtil(jsonStr);
        System.debug('*** ' + jsnGen2.getValue('hostId'));
        System.debug('*** ' + jsnGen2.getValue('pickup|undefinedKey|floor'));
        System.debug('***null ' + jsnGen2.getValue('pickup|[1]|undefinedKey|[3]|floor'));
        jsnGen2.putValue('hostId', 'host ID changed for test');
        jsnGen2.putValue('firstStop|testKey|[1]|[0]', 'Test TEST');
        System.debug('*** ' + jsnGen2.buildJson());
    }*/
   
}