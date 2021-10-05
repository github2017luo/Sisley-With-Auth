import { LightningElement, api } from 'lwc';
import searchAccountsRCU from '@salesforce/apex/API_Star_RCU_Service.searchAccountsRCU';
import synchronize from '@salesforce/apex/API_Star_RCU_Service.synchronize';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RcuTable extends LightningElement {

    @api recordId;

    data = [];
    columnNames = [];
    // queryTerm;
    isLoading;
    // valueAndIdMap = new Map();
    selectedRow;
    isChecked;
    rowsArr = [];
    connectedCallback() {
        console.log('recordId ' + this.recordId);
        //console.log('data => ' + this.data);

        this.initializeData();
    }

    initializeData() {
        this.isLoading = true;
        searchAccountsRCU({ accountId: this.recordId })
            .then(result => {
                result = JSON.parse(result);
                console.log('result', result);

                //converting response to displayable data
                this.columnNames = result[0].Row;
                let data = [];
                for (let row of result) {
                    let rowData = {};
                    for (let entry of row.Row) {
                        rowData[entry.FieldName] = entry.FieldValue;
                    }
                    data = [...data, rowData];
                }
                console.log('data', data);
                this.data = data;

                this.isLoading = false;
            })
            .catch(error => {
                 this.showError(error);
                console.log('error', error);
                this.isLoading = false;
            });
    }


    handleSync() {
            this.isLoading = true;
            synchronize({ accountId: this.recordId, rcuId: this.selectedRow })
                .then(result => {
                    console.log(result);
                    this.showToast('', 'row with id: ' + this.selectedRow + ' synchronized successfully!', false);
                    this.isLoading = false;
                })
                .catch(error => {
                    this.showError(error);
                    console.log('error', error);
                    this.isLoading = false;
                });
        
    }



    handleCheckboxChange(event) {

        this.selectedRow = event.currentTarget.dataset.id;
        this.isChecked = event.target.checked;
        // console.log('selected',this.selectedRow);
        // console.log('isChecked',this.isChecked);

        if(!this.isChecked) this.selectedRow = null;
    }


    showError(error) {
        if(!!error.body && !!error.body.message) {
            this.showToast(null, error.body.message, true);
        } else if(!!error.body && !!error.body.fieldErrors && Object.keys(error.body.fieldErrors).length > 0) {
            for(let err in error.body.fieldErrors) {
                this.showToast(error.body.fieldErrors[err][0].statusCode + ' : ' + err, error.body.fieldErrors[err][0].message, true);
            }
        } else if(!!error.body && !!error.body.pageErrors && error.body.pageErrors.length > 0) {
            for(let err of error.body.pageErrors) {
                this.showToast(err.statusCode, err.message, true);
            }
        } else {
            this.showToast(null, 'Unknown error. Check browser log (F12).', true);
        }
    }

    showToast(title, message, isError) {
        const event = new ShowToastEvent({
            title,
            message,
            variant: isError ? 'error' : 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


}