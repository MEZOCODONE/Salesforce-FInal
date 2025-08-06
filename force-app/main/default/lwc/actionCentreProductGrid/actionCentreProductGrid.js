import { LightningElement, wire, track } from 'lwc';
import getCentreProducts from '@salesforce/apex/ActionCentreController.getCentreProducts';
import getCurrencyRates from '@salesforce/apex/CurrencyController.getCurrencyRates';
import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class ActionCentreProductGrid extends LightningElement {
    @track recordId;
    @track products = [];
    @track productsRaw = [];
    @track selectedProduct;
    @track selectedCurrency = 'USD';
    @track exchangeRates = {
        USD: 1,
        EUR: null,
        BYN: null
    };

    showModal = false;

    @wire(MessageContext)
    messageContext;

    @wire(getCentreProducts, { centreId: '$recordId' })
    wiredProducts({ data, error }) {
        if (data) {
            this.productsRaw = data;
            this.products = this.getConvertedProducts(data);
        } else if (error) {
            this.showToast('Load Error', 'Failed to retrieve centre products.', 'error');
        }
    }

    connectedCallback() {
        const pathSegments = window.location.pathname.split('/');
        const id = pathSegments.find(p => p.startsWith('a00'));
        this.recordId = id;
        this.loadExchangeRates();
    }

    async loadExchangeRates() {
        try {
            const result = await getCurrencyRates();
            this.exchangeRates = {
                USD: 1,
                EUR: result.EUR,
                BYN: result.BYN
            };
            this.products = this.getConvertedProducts(this.productsRaw);
        } catch (e) {
            this.showToast('Failed to load currency rates', e.body?.message || e.message);
        }
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        this.products = this.getConvertedProducts(this.productsRaw);
    }

    getConvertedProducts(products) {
        const rate = this.exchangeRates[this.selectedCurrency] || 1;

        return products.map(p => ({
            ...p,
            convertedPrice: (p.UnitPrice * rate).toFixed(2)
        }));
    }

    get currencyOptions() {
        return [
            { label: 'USD', value: 'USD' },
            { label: 'EUR', value: 'EUR' },
            { label: 'BYN', value: 'BYN' }
        ];
    }

    handleExportClick() {
        const url = `/vforcesite/CentreProceduresToPdf?centreId=${this.recordId}&currency=${this.selectedCurrency}`;
        window.open(url, '_blank');
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
