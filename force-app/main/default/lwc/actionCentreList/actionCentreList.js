import { LightningElement, wire, track } from 'lwc';
import getActionCentres from '@salesforce/apex/ActionCentreController.getActionCentres';
import getAllProceduresWithMinimalPrice from '@salesforce/apex/ProcedureController.getAllProceduresWithMinimalPrice';
import { MessageContext, publish } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';
import getCurrencyRates from '@salesforce/apex/CurrencyController.getCurrencyRates';


export default class ActionCentreList extends LightningElement {
    @track viewType = 'centres';
    @track centres = [];
    @track procedures = [];
    @track error;

    @track selectedCurrency = 'USD';
    @track exchangeRates = {
        USD: 1,
        EUR: null,
        BYN: null
    };

    @wire(MessageContext)
    messageContext;

    showToast(title, message, variant = 'error') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }

    get typeOptions() {
        return [
            { label: 'Centres', value: 'centres' },
            { label: 'Procedures', value: 'procedures' }
        ];
    }

    get currencyOptions() {
        return [
            { label: 'USD', value: 'USD' },
            { label: 'EUR', value: 'EUR' },
            { label: 'BYN', value: 'BYN' }
        ];
    }

    handleTypeChange(event) {
        this.viewType = event.detail.value;
        this.error = null;
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        this.recalculatePrices();
    }

    connectedCallback() {
        this.loadExchangeRates();
    }

    @wire(getActionCentres)
    wiredCentres({ data, error }) {
        if (data) {
            this.centres = data.map(centre => ({
                ...centre,
                url: `/action-centre/${centre.Id}`
            }));
        } else if (error) {
            this.showToast('Failed to load centres', error?.body?.message || error.message);
            this.error = error;
            this.centres = [];
        }
    }

    @wire(getAllProceduresWithMinimalPrice)
    wiredProcedures({ data, error }) {
        if (data) {
            const raw = Object.values(data).map(p => ({
                ...p,
                url: `/product/${p.id}`
            }));
            this.procedures = raw;
            try {
                this.recalculatePrices();
            } catch (e) {
                this.showToast('Price recalculation error', e.message);
            }
        } else if (error) {
            this.showToast('Failed to load procedures', error?.body?.message || error.message);
            this.error = error;
            this.procedures = [];
        }
    }
    
    async loadExchangeRates() {
        try {
            const result = await getCurrencyRates();
            this.exchangeRates = {
                USD: 1,
                EUR: result.EUR,
                BYN: result.BYN
            };
            this.recalculatePrices();
        } catch (e) {
            this.showToast('Failed to load currency rates', e.body?.message || e.message);
        }
    }


    recalculatePrices() {
        try {
            if (!this.procedures?.length || !this.exchangeRates[this.selectedCurrency]) return;

            const rate = this.exchangeRates[this.selectedCurrency];
            this.procedures = this.procedures.map(p => ({
                ...p,
                convertedPrice: (p.price * rate).toFixed(2)
            }));
        } catch (e) {
            this.showToast('Price recalculation error', e.message);
        }
    }

    get hasCentres() {
        return this.viewType === 'centres' && this.centres.length > 0;
    }

    get hasProcedures() {
        return this.viewType === 'procedures' && this.procedures.length > 0;
    }

    get pdfUrl() {
        return `/vforcesite/ProceduresToPdf?currency=${this.selectedCurrency}`;
    }

    handleExportClick(event) {
    console.log('Export PDF clicked');

    window.open(this.pdfUrl, '_blank');
}
}
