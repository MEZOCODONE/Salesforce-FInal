import { LightningElement, wire, track } from 'lwc';
import getCentreById from '@salesforce/apex/ActionCentreController.getCentreById';
import getNursesByActionCentre from '@salesforce/apex/NurseController.getNursesByActionCentre';
import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class ActionCentreCard extends LightningElement {
    @track recordId;
    @track centre;
    @track nurses = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        const pathSegments = window.location.pathname.split('/');
        const id = pathSegments.find(segment => segment.startsWith('a00'));
        if (id) {
            this.recordId = id;
        } else {
            this.showToast('Error', 'Centre ID not found in URL');
        }
    }

    @wire(getCentreById, { centreId: '$recordId' })
    wiredCentre({ data, error }) {
        if (data) {
            this.centre = data;
            this.loadNurses();
        } else if (error) {
            this.showToast('Error loading centre', error?.body?.message || error.message, 'error');
        }
    }

    loadNurses() {
        getNursesByActionCentre({ centreId: this.recordId })
            .then(data => {
                this.nurses = data || [];
            })
            .catch(error => {
                this.showToast('Error loading nurses', error?.body?.message || error.message, 'error');
            });
    }

    showToast(title, message, variant = 'error') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }

    get isClientSupportCentre() {
        return this.centre?.RecordType?.Name === 'Client Support Centre';
    }
}
