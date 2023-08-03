import { LightningElement, api,track } from 'lwc';
import createCardToken from "@salesforce/apex/StripeCalloutHandler.paymentMethodController";
 
export default class AddCardPage1 extends LightningElement {
    @api recordId;
    @track cardNumber = '';
    @track cardholderName = '';
    @track expirationMonth = '';
    @track expirationYear = '';
    @track cvv = '';
    @track methodValue = 'card';

    get methodOptions() {
        return [
            { label: 'Card', value: 'card' },
            { label: 'ACH', value: 'ach' },
        ];
    }

    handleCardNumberChange(event) {
        this.cardNumber = event.target.value;
    }

    handleCardholderNameChange(event) {
        this.cardholderName = event.target.value;
    }

    handleExpirationMonthChange(event) {
        this.expirationMonth = event.target.value;
    }

    handleExpirationYearChange(event) {
        this.expirationYear = event.target.value;
    }

    handleCVVChange(event) {
        this.cvv = event.target.value;
    }

    handleNext() {
        // You can implement the logic to save the card details here
        // For example, you can call an Apex method to save the details to the database.
        // You can also perform data validation before saving the details.
        // For simplicity, we won't implement the actual save logic in this example.
        // Instead, we'll just log the card details to the console.
        console.log('Card Number:', this.cardNumber);
        console.log('Cardholder Name:', this.cardholderName);
        console.log('Expiration Month:', this.expirationMonth);
        console.log('Expiration Year:', this.expirationYear);
        console.log('CVV:', this.cvv);

        createCardToken({recordId : this.recordId, cardNumber : this.cardNumber, cardHolderName : this.cardholderName, expMonth : this.expirationMonth, expYear : this.expirationYear, cvv : this.cvv})
        .then((result) => {
          
        })
        .catch((error) => {
          console.log(error);
        });
    }
}