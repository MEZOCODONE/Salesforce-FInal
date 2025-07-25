import { LightningElement, wire, track } from 'lwc';
import getCentreProducts from '@salesforce/apex/ActionCentreController.getCentreProducts';
import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class ActionCentreProductGrid extends LightningElement {
    @track recordId;
    @track products = [];
    @track nurses = [];
    @track selectedProduct;

    showModal = false;

    @wire(MessageContext)
    messageContext;

    @wire(getCentreProducts, { centreId: '$recordId' })
    wiredProducts({ data, error }) {
        if (data) {
            this.products = data;
        } else if (error) {
            this.showToast('Load Error', 'Failed to retrieve centre products.', 'error');
        }
    }

    connectedCallback() {
        const pathSegments = window.location.pathname.split('/');
        const id = pathSegments.find(p => p.startsWith('a00'));
        this.recordId = id;
    }

    async handleMakeAppointment(event) {
        const productId = event.currentTarget.dataset.id;

        this.selectedProduct = null;
        this.showModal = false;

        await Promise.resolve();

        this.selectedProduct = this.products.find(p => p.Id === productId);
        if (!this.selectedProduct) {
            this.showToast('Product Not Found', `Product with Id: ${productId} was not found.`, 'warning');
            return;
        }

        this.showModal = true;
    }

    handleModalClose() {
        this.showModal = false;
    }

    showToast(title, message, variant) {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }
}
