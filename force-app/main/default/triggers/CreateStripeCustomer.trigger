trigger CreateStripeCustomer on OpportunityContactRole (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityContactRoleTriggerHandler.stripeIntegration(trigger.new[0]);

        }
    }
}