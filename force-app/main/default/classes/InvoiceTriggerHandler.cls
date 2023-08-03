public class InvoiceTriggerHandler {
    public static void stripeIntegration(Invoice__c inv){
        
        createInvoice(inv.Id);
    }

    @future(callout =true)
    public static void createInvoice(Id inv){
        Id oppParentId = [SELECT Id,Opportunity__c FROM Invoice__c WHERE Id=:inv].Opportunity__c;
        OpportunityContactRole ocr = [SELECT Stripe_Customer_Id__c FROM OpportunityContactRole WHERE OpportunityId=:oppParentId AND IsPrimary = true LIMIT 1];
        HttpRequest req = new HttpRequest();
        String endPointURL = 'https://api.stripe.com/v1/invoices';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String bodyData = 'customer='+ocr.Stripe_Customer_Id__c;
        req.setBody(bodyData);
        system.debug('--reqbody--');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        System.debug('Status code = '+response.getStatusCode());
        if(response.getStatusCode() == 200 ){
            system.debug('-Response--'+response.getBody());

            Map<String, Object> serializeResponseBody = new Map<String, Object>();
            serializeResponseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('serializeResponseBody>>'+(String)serializeResponseBody.get('id'));
            String res = (String)serializeResponseBody.get('id');
            Invoice__c updateInv = [SELECT Id,Stripe_Invoice_Id__c FROM Invoice__c WHERE Id=:inv];
            updateInv.Stripe_Invoice_Id__c = res;
            update updateInv;


            // HttpRequest req1 = new HttpRequest();
            // String endPointURL1 = 'https://api.stripe.com/v1/invoices/'+res+'/send';
            // req1.setEndpoint(endPointURL);
            // req1.setMethod('POST');
            // req1.setHeader('Authorization','Bearer sk_test_51NYOozSHazhHgo0aEubziZblH1RnXudNPyJeVb1qsTZRrsMXVRdJjOkvejd89RURCszHysC6Z527enzeKZSApBoO00xbrzeflQ'); 
            // //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            // Http http1 = new Http();
            // HTTPResponse response1 = http1.send(req1);
            // //Response Handle
            // System.debug('Status code = '+response1.getStatusCode());
            // if(response1.getStatusCode() == 200 ){
            //     system.debug('-Response--'+response1.getBody());
            // }
            
            
    
        }
    }

}