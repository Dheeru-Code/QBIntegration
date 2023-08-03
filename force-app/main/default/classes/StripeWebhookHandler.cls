@RestResource(urlMapping='/stripe/stripewebhook')
global with sharing class StripeWebhookHandler {
    
    @HttpPost
    global static void handleWebhook() {
        System.debug('In web service');
        String requestBody = RestContext.request.requestBody.toString();
        System.debug('Webhook: ' + requestBody);

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);

        Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
        Map<String, String> objectMap = (Map<String, String>)dataMap.get('object');
        String invId = (String)objectMap.get('id');
        system.debug(invId);
        Invoice__c updateInv = [SELECT Id,Stripe_Invoice_Id__c,Paid_Status__c FROM Invoice__c WHERE Stripe_Invoice_Id__c=:invId];

        updateInv.Paid_Status__c = true;
        update updateInv;

        
        RestContext.response.statusCode = 200;
    }

}