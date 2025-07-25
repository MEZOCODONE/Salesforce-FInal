import { LightningElement, wire, track } from 'lwc';
import getProductById from '@salesforce/apex/ProcedureController.getProductById';
import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class ProcedureCard extends LightningElement {
    @track recordId;
    @track product;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        const pathSegments = window.location.pathname.split('/');
        const productId = pathSegments.find(p => p.startsWith('01t'));
        if (productId) {
            this.recordId = productId;
        } else {
            this.showToast('Error', 'Product ID not found in URL');
        }
    }

    @wire(getProductById, { productId: '$recordId' })
    wiredProduct({ data, error }) {
        if (data) {
            this.product = data;
        } else if (error) {
            this.showToast('Error loading product', error?.body?.message || error.message, 'error');
        }
    }

    showToast(title, message, variant = 'error') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }
}
