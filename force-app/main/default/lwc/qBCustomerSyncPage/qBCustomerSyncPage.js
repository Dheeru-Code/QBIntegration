import { LightningElement,api } from 'lwc';
import LightningConfirm from "lightning/confirm";
import QBSync from '@salesforce/apex/QBCustomerSyncController.QBSync';

export default class QBCustomerSyncPage extends LightningElement {
    @api recordId;

    @api async invoke(){
        const result = await LightningConfirm.open({
            message: "Do you want to Sync with QuickBook customer?",
            theme: "success",
            label: "Are you sure?"
          });
          if(result){
            console.log('before calling apex');
            QBSync({recordId:this.recordId})
            .then(result=>{
                console.log('Synced');
            })
            .catch(error=>{
            });
    
          }
    }
    

}