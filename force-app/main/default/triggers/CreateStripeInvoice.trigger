trigger CreateStripeInvoice on Invoice__c (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            InvoiceTriggerHandler.stripeIntegration(trigger.new[0]);

        }
    }
}