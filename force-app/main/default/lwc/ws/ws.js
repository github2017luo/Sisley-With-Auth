import { LightningElement, api } from 'lwc';

export default class Ws extends LightningElement {

    @api recordId;

    connectedCallback() {
        console.log('recordId',this.recordId);
    }

}