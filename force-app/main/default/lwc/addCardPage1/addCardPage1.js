import { LightningElement,wire, api,track } from 'lwc';
import createCardToken from "@salesforce/apex/StripeCalloutHandler.paymentMethodController";
import createPaymentIntent from "@salesforce/apex/StripeCalloutHandler.createPaymentIntent";
import getPmList from "@salesforce/apex/StripeCalloutHandler.getPmList";
export default class AddCardPage1 extends LightningElement {
    @track pmColumns = [{
        label: 'Card Brand',
        fieldName: 'Card_Brand__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Payment Method Type',
        fieldName: 'Payment_Methods__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Card Holder Name',
        fieldName: 'Card_Holder_Name__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Card Number',
        fieldName: 'Card_Number__c',
        type: 'text',
        sortable: true
    }
    ];

    @track pmList ;
    @track isPmListVisible = true;
    @track isPaymentPageVisible = false;
    @api recordId;
    @track cardNumber = '';
    @track cardholderName = '';
    @track expirationMonth = '';
    @track expirationYear = '';
    @track cvv = '';
    @track currencyType = '';
    @track amount;
    @track selectedRecords=[];
    @track methodValue = 'card';
    @track isAddPmVisible = false;

    @wire(getPmList , {oppId:'$recordId'})
    wiredPaymentMethods({error,data}) {
        if (data) {
            this.pmList = data;
        } else if (error) {
            
        }
    }
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

    handleCurrencyChange(event) {
        this.currencyType = event.target.value;
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }
    
    handleAddPm(){
        this.isAddPmVisible = true;
        this.isPaymentPageVisible = false;
        this.isPmListVisible = false;
    }

    handleProceed(){
        this.selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords -> ',this.selectedRecords);
        console.log(this.selectedRecords[0]);
        this.isAddPmVisible = false;
        this.isPaymentPageVisible = true;
        this.isPmListVisible = false;
        
    }

    handlePayout() {
        createPaymentIntent({amount : this.amount, currencyType : this.currencyType, pmData : this.selectedRecords[0] })
        .then((result) => {
            this.isAddPmVisible = false;
            this.isPaymentPageVisible = false;
            this.isPmListVisible = true;
        })
        .catch((error) => {
          console.log(error);
        });
    }

    handleSavePm() {
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
            this.isAddPmVisible = false;
            this.isPaymentPageVisible = false;
            this.isPmListVisible = true;
        })
        .catch((error) => {
          console.log(error);
        });
    }
}