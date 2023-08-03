@RestResource(urlMapping='/quickbook/quickbookswebhook')
global class QuickBooksWebhookHandler {

    @HttpPost
    global static void handleWebhook() {
        System.debug('In web service');
        String requestBody = RestContext.request.requestBody.toString();
        System.debug('Webhook: ' + requestBody);

        String qbId;
        //Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);



        // Deserialize the JSON response
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);

        // Access the 'eventNotifications' list
        List<Object> eventNotifications = (List<Object>)responseMap.get('eventNotifications');

        // Check if the list is not empty and get the first element (assuming there's only one element in the list)
        if (!eventNotifications.isEmpty()) {
            Map<String, Object> eventNotification = (Map<String, Object>)eventNotifications[0];

            // Access the 'dataChangeEvent' map
            Map<String, Object> dataChangeEvent = (Map<String, Object>)eventNotification.get('dataChangeEvent');

            // Access the 'entities' list
            List<Object> entities = (List<Object>)dataChangeEvent.get('entities');

            // Iterate through the 'entities' list to get the 'id' values
            for (Object entity : entities) {
                Map<String, Object> entityMap = (Map<String, Object>)entity;
                String entityId = (String)entityMap.get('id');
                System.debug('ID: ' + entityId);
                qbId = entityId;
                // You can do whatever you want with the 'id' value here.
                if(entityMap.get('operation')=='Create'){
                    getQbChanges(qbId);
                }
                else if(entityMap.get('operation')=='Update'){
                    updateSFData(qbId);
                }
                else if(entityMap.get('operation')==''){
                    deleteSFData(qbId);
                }
                
            }
        }


        
        RestContext.response.statusCode = 200;
    }

    @future(callout =true)
    public static void getQbChanges(String quickbookId){
        HttpRequest req = new HttpRequest();
        String endPointURL = 'callout:qb/v3/company/4620816365319268220/account/'+quickbookId+'?minorversion=65';
        req.setEndpoint(endPointURL);
        req.setMethod('GET');
        req.setHeader('Content-Type','text/plain');
        req.setHeader('Accept','application/json'); 
        req.setTimeout(120000);
        system.debug('--req--'+req);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        System.debug('Status code = '+response.getStatusCode());
        if(response.getStatusCode() == 200 ){
            system.debug('-Response--'+response.getBody());
            system.debug('--deserialize'+(Map<String, Object>)JSON.deserializeUntyped(response.getBody()));

            Map<String, Object> serializeResponseBody = new Map<String, Object>();
            serializeResponseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('serializeResponseBody>>'+JSON.serializePretty(serializeResponseBody));
            Map<String, Object> res = (Map<String, Object>)serializeResponseBody.get('Account');
            System.debug(res);
            System.debug(res.get('Id'));
            System.debug(res.get('SyncToken'));

            Account newAcc = new Account(Name=(String)res.get('Name'),QB_Id__c = (String)res.get('Id'),QB_Sync_Token__c = (String)res.get('SyncToken'));
            Insert newAcc;
        }    
 
    }
    
    @future(callout =true)
    public static void updateSFData(String quickbookId){
        HttpRequest req = new HttpRequest();
        String endPointURL = 'callout:qb/v3/company/4620816365319268220/account/'+quickbookId+'?minorversion=65';
        req.setEndpoint(endPointURL);
        req.setMethod('GET');
        req.setHeader('Content-Type','text/plain');
        req.setHeader('Accept','application/json'); 
        req.setTimeout(120000);
        system.debug('--req--'+req);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        System.debug('Status code = '+response.getStatusCode());
        if(response.getStatusCode() == 200 ){
            system.debug('-Response--'+response.getBody());
            system.debug('--deserialize'+(Map<String, Object>)JSON.deserializeUntyped(response.getBody()));

            Map<String, Object> serializeResponseBody = new Map<String, Object>();
            serializeResponseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('serializeResponseBody>>'+JSON.serializePretty(serializeResponseBody));
            Map<String, Object> res = (Map<String, Object>)serializeResponseBody.get('Account');
            System.debug(res);
            System.debug(res.get('Id'));
            System.debug(res.get('SyncToken'));
            String s =  String.valueOf(res.get('Id')).remove('"');
            System.debug(s);
            String query = 'SELECT Id,Name,QB_Id__c,QB_Sync_Token__c from Account where QB_Id__c=\''+s+'\' LIMIT 1';
            Account updateAcc =  Database.query(query);
            if(updateAcc.QB_Sync_Token__c != res.get('SyncToken')){
                updateAcc.Name = (String)res.get('Name');
                updateAcc.QB_Sync_Token__c = (String)res.get('SyncToken');
                update updateAcc;
            }
        }    
 
    }
    
}