public class QBCustomerSyncController {
    // @AuraEnabled
    // public static void QBSync(Id recordId){
    //     Account acc = [SELECT Id,Name,QB_Id__c,QB_Sync_Token__c, ShippingCity, ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode, Phone, BillingCity, BillingStreet, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude FROM Account WHERE Id=:recordId];
    //     QBCallout callout = new QBCallout();
    //     QBCustomerJSON accountData = callout.getCustomer(acc);

    //     if(accountData.QueryResponse.Customer != null){
    //         if(accountData.QueryResponse.Customer.size() == 1){
    //             for(QBCustomerJSON.Customer c : accountData.QueryResponse.Customer){
                    
    //                 acc.QB_Id__c = c.Id;
    //                 acc.QB_Sync_Token__c = c.SyncToken;
    //                 System.debug(acc.QB_Id__c);
    //                 System.debug(acc.QB_Sync_Token__c);
    //             }
    //         }
    //     }

    //     // QBCustomerResponseJSON accountPushData = callout.createCustomerCall(acc);
    //     // System.debug(accountPushData);
    //     // acc.QB_Id__c = accountPushData.Customer.Id;
    //     // acc.QB_Sync_Token__c = accountPushData.Customer.SyncToken;

    //     callout.updateRefreshToken();

    //     update acc;

    // }
    
    public static Id SFID;
    public static Account acc = new account();
    @AuraEnabled
    public static void QBSync(Id recordId){
        //get account        
        acc = [SELECT Id,Name,QB_Id__c,QB_Sync_Token__c from account where Id =:recordId LIMIT 1];
       //Data map Preparation
        map<String,Object> mainMap = new map<String,Object>();
        System.debug('id  '+acc.Id);
        mainMap.put('Name', acc.Name);
        mainMap.put('AccountType', 'Accounts Receivable');
        System.debug(mainMap);
        if(acc.QB_Id__c==null && acc.QB_Sync_Token__c==null){
            //Calling Async method for callout 
            System.debug('new account for quickbook');
            insertAccountOnQuickBook(JSON.serializePretty(mainMap));
        }else{
            System.debug('old account for quickbook');
            mainMap.put('Id',acc.QB_Id__c);
            mainMap.put('SyncToken',acc.QB_Sync_Token__c);
            updateAccountOnQuickBook(JSON.serializePretty(mainMap));
        }  
     }


    @future(callout =true)
    public static void insertAccountOnQuickBook(String jsonData){
        //new request
        HttpRequest req = new HttpRequest();
        String endPointURL = 'callout:qb/v3/company/4620816365319268220/account?minorversion=65';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json'); 
        req.setBody(jsonData);
        req.setTimeout(120000);
        system.debug('--reqbody--'+jsonData);
        system.debug(acc.Id);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        System.debug('Status code = '+response.getStatusCode());
        Map<String, Object> m= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        System.debug('salesforce Name = '+ m.get('Name'));
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
            Account updateAcc =  [SELECT Id,Name,QB_Id__c,QB_Sync_Token__c from account where Name =:(String)res.get('Name') LIMIT 1];
            updateAcc.QB_Id__c = (String)res.get('Id');
            updateAcc.QB_Sync_Token__c = (String)res.get('SyncToken');
            update updateAcc;

        }
    }

    @future(callout =true)
    public static void updateAccountOnQuickBook(String jsonData){
        //new request
        HttpRequest req = new HttpRequest();
        String endPointURL = 'callout:qb/v3/company/4620816365319268220/account?minorversion=65';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json'); 
        req.setBody(jsonData);
        req.setTimeout(120000);
        system.debug('--reqbody--'+jsonData);
        system.debug(acc.Id);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        System.debug('Status code = '+response.getStatusCode());
        Map<String, Object> m= (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        System.debug('salesforce Name = '+ m.get('Name'));
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
            Account updateAcc =  [SELECT Id,Name,QB_Id__c,QB_Sync_Token__c from account where QB_Id__c=:(String)res.get('Id') LIMIT 1];
            updateAcc.QB_Sync_Token__c = (String)res.get('SyncToken');
            update updateAcc;

        }
    }
   
}