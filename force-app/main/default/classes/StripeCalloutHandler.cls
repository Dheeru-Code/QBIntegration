public class StripeCalloutHandler {
    @AuraEnabled
    public static void paymentMethodController(Id recordId, String cardNumber, String cardHolderName, String expMonth, String expYear, String cvv){
        String bodyData = 'card[number]='+cardNumber+'&card[name]='+cardHolderName+'&card[exp_month]='+expMonth+'&card[exp_year]='+expYear+'&card[cvc]='+cvv;
        createToken(bodyData,recordId);
    }
    

    @future(callout =true)
    public static void createToken(String bodyData,Id oppId){
        HttpRequest req = new HttpRequest();
        String endPointURL = 'https://api.stripe.com/v1/tokens';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
        
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
            String tokenId = (String)serializeResponseBody.get('id');


            //create payment method callout 
            HttpRequest req1 = new HttpRequest();
            String endPointURL1 = 'https://api.stripe.com/v1/payment_methods';
            req1.setEndpoint(endPointURL1);
            req1.setMethod('POST');
            req1.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
            String bodyData1 = 'type=card&card[token]='+tokenId;
            req1.setBody(bodyData1);
            system.debug('--reqbody--'+bodyData1);
            Http http1 = new Http();
            HTTPResponse response1 = http1.send(req1);
            //Response Handle
            System.debug('Status code = '+response1.getStatusCode());
            if(response1.getStatusCode() == 200 ){
                system.debug('-Response--'+response1.getBody());

                Map<String, Object> serializeResponseBody1 = new Map<String, Object>();
                serializeResponseBody1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                System.debug('serializeResponseBody>>'+(String)serializeResponseBody1.get('id'));
                String pmId = (String)serializeResponseBody1.get('id');



                //Attach payment method to customer
                OpportunityContactRole ocr = [SELECT Stripe_Customer_Id__c FROM OpportunityContactRole WHERE OpportunityId=:oppId AND IsPrimary = true LIMIT 1];
                
                HttpRequest req2 = new HttpRequest();
                String endPointURL2 = 'https://api.stripe.com/v1/payment_methods/'+pmId+'/attach';
                req2.setEndpoint(endPointURL2);
                req2.setMethod('POST');
                req2.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
                String bodyData2 = 'customer='+ocr.Stripe_Customer_Id__c;
                req2.setBody(bodyData2);
                system.debug('--reqbody--'+bodyData2);
                Http http2 = new Http();
                HTTPResponse response2 = http2.send(req2);
                //Response Handle
                System.debug('Status code = '+response2.getStatusCode());


                Map<String, Object> cardMap = (Map<String, Object>) serializeResponseBody1.get('card');
                Map<String, Object> billingDetailMap = (Map<String, Object>) serializeResponseBody1.get('billing_details');
                String encryptCard = '**** **** **** '+(String)cardMap.get('last4');
                Payment_Method__c pm = new Payment_Method__c(Payment_Methods__c='Card', Token_Id__c=tokenId, Opportunity__c = oppId, Stripe_PM_Id__c = pmId, Card_Number__c = encryptCard, Card_Brand__c = (String)cardMap.get('brand'), Card_Holder_Name__c = (String)billingDetailMap.get('name'));
                insert pm;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Payment_Method__c> getPmList(Id oppId) {
        return [SELECT Id,Opportunity__c, Card_Brand__c, Card_Holder_Name__c, Card_Number__c, Payment_Methods__c, Stripe_PM_Id__c, Token_Id__c FROM Payment_Method__c WHERE Opportunity__c = :oppId];
    }

    @AuraEnabled
    public static void createPaymentIntent(Integer amount, String currencyType, Map<String,String> pmData){
        System.debug(amount);
        System.debug(currencyType);
        System.debug(pmData);
        System.debug(pmData.get('Stripe_PM_Id__c'));
        System.debug(pmData.get('Opportunity__c'));
        OpportunityContactRole ocr = [SELECT Stripe_Customer_Id__c FROM OpportunityContactRole WHERE OpportunityId=:pmData.get('Opportunity__c') AND IsPrimary = true LIMIT 1];
        String bodyData = 'amount='+amount+'&currency='+currencyType+'&confirm=true&customer='+ocr.Stripe_Customer_Id__c+'&payment_method='+pmData.get('Stripe_PM_Id__c');
        paymentIntentCallout(bodyData);
    }

    @future(callout =true)
    public static void paymentIntentCallout(String bodyData){
        HttpRequest req = new HttpRequest();
        String endPointURL = 'https://api.stripe.com/v1/payment_intents';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer sk_test_51MQpPmCqqBdj2v0QXC1VlKWBZkPmDpp5AB5oWVkj2nX7J021dQYhDf4Z9qDzdAH81CbqkZV5cPt9aO8Z3ybXE12d00PaV9EvZX'); 
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

    
        }
    }

}