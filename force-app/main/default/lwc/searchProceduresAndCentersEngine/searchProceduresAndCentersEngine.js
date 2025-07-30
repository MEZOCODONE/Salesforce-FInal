import { LightningElement, track, wire } from 'lwc';
import searchCentres from '@salesforce/apex/ActionCentreController.searchCentres';
import searchProcedures from '@salesforce/apex/ProcedureController.searchProcedures';
import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class SearchProceduresAndCentersEngine extends LightningElement {
    @track searchTerm = '';
    @track suggestions = [];
    @track searchType = 'centre';

    @wire(MessageContext)
    messageContext;

    showToast(title, message, variant = 'info') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }

    get typeOptions() {
        return [
            { label: 'Centers', value: 'centre' },
            { label: 'Procedures', value: 'procedure' }
        ];
    }

    handleTypeChange(event) {
        this.searchType = event.detail.value;
        this.suggestions = [];
        this.searchTerm = '';
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;

        if (this.searchTerm.length > 0) {
            this.fetchSuggestions();
        } else {
            this.suggestions = [];
        }
    }

    fetchSuggestions() {
        if (this.searchType === 'centre') {
            searchCentres({ searchTerm: this.searchTerm })
                .then(result => {
                    this.suggestions = result;
                })
                .catch(error => {
                    this.showToast('Error searching centres', error?.body?.message || error.message, 'error');
                    this.suggestions = [];
                });
        } else {
            searchProcedures({ searchTerm: this.searchTerm })
                .then(result => {
                    this.suggestions = result;
                })
                .catch(error => {
                    this.showToast('Error searching procedures', error?.body?.message || error.message, 'error');
                    this.suggestions = [];
                });
        }
    }

    handleSuggestionSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedName = event.currentTarget.innerText;

        this.showToast('Redirecting', `Opening: ${selectedName}`, 'info');

        if (this.searchType === 'centre') {
            window.location.href = `/action-centre/${selectedId}`;
        } else {
            window.location.href = `/procedure/${selectedId}`;
        }
    }
}
