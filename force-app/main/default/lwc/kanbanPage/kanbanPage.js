import { LightningElement,track,wire,api } from 'lwc';
import getObjectApiNames from '@salesforce/apex/kanbanPageHandler.getObjectApiNames';
import getPicklistFields from '@salesforce/apex/kanbanPageHandler.getPicklistFields';
import getPicklistValues from '@salesforce/apex/kanbanPageHandler.getPicklistValues';

export default class KanbanPage extends LightningElement {
    @track objectOptions = [];
    @track picklistFieldOptions = [];
    @track selectedObjectApiName;
    @track selectedFieldApiName;
    @track isKanbanVisible = false;
    @track picklistValues = [];


    @wire(getObjectApiNames)
    wiredObjectApiNames({ data, error }) {
        if (data) {
            this.objectOptions = data.map(apiName => {
                return { label: apiName, value: apiName };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleObjectChange(event) {
        this.selectedObjectApiName = event.detail.value;
        console.log(this.selectedObjectApiName);
        if (this.selectedObjectApiName) {
            this.loadPicklistFields(this.selectedObjectApiName);
        }
    }
    picklistValueSet;
    handlePicklistFieldChange(event) {
        this.selectedFieldApiName = event.detail.value;
        console.log(this.selectedFieldApiName);
        getPicklistValues({ objectApiName: this.selectedObjectApiName, fieldApiName: this.selectedFieldApiName })
        .then((result) => {
            console.log(result);
            // this.picklistValues = result;
            // console.log(JSON.parse(JSON.stringify(this.picklistValues)));
            // this.picklistValueSet = JSON.parse(JSON.stringify(this.picklistValues)).keyset();
            // console.log(this.picklistValueSet);
            // this.isKanbanVisible = true;
        })
        .catch((error) => {
            console.log(error);
        });
    }

    async loadPicklistFields(objectApiName) {
        try {
            const picklistFields = await getPicklistFields({ objectApiName });
            this.picklistFieldOptions = picklistFields.map(field => {
                return { label: field.label, value: field.value };
            });
        } catch (error) {
            console.error(error);
        }
    }

}