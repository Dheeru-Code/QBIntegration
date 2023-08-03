public class OpportunityContactRoleTriggerHandler {
    public static void stripeIntegration(OpportunityContactRole oppConRole){
        

        createCustomer((String)oppConRole.Id);
    }

    @future(callout =true)
    public static void createCustomer(String sfId){
        OpportunityContactRole contactRole = [SELECT Id,Contact.FirstName,Contact.Email,Opportunity.Amount FROM OpportunityContactRole where Id=:sfId];
        HttpRequest req = new HttpRequest();
        String endPointURL = 'https://api.stripe.com/v1/customers';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String bodyData = 'name='+contactRole.Contact.FirstName+'&email='+contactRole.Contact.Email;
        req.setBody(bodyData);
        system.debug('--reqbody--'+bodyData);
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
            System.debug(sfId);
            OpportunityContactRole ocr = [SELECT Id,Stripe_Customer_Id__c FROM OpportunityContactRole WHERE Id=:sfId];
            ocr.Stripe_Customer_Id__c = res;
            update ocr;
        }
    }
}