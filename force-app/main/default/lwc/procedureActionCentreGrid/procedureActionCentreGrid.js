import { LightningElement, track, wire } from 'lwc';
import getCentresByProductId from '@salesforce/apex/ActionCentreController.getCentresByProduct';
import getProductPriceInPricebook from '@salesforce/apex/ProcedureController.getProductPriceInPricebook';
import getProductById from '@salesforce/apex/ProcedureController.getProductById';

import { publish, MessageContext } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class ProcedureActionCentreGrid extends LightningElement {
    @track centresWithPrice = [];
    @track recordId;

    @track selectedCentre = null;
    @track selectedProduct = null;
    @track selectedPrice = null;
    @track showModal = false;

    @wire(MessageContext)
    messageContext;

    showToast(title, message, variant = 'error') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }

    connectedCallback() {
        const pathSegments = window.location.pathname.split('/');
        const productId = pathSegments.find(segment => segment.startsWith('01t'));
        this.recordId = productId;

        if (!this.recordId) {
            this.showToast('Ошибка', 'ID продукта не найден в URL');
            return;
        }

        getCentresByProductId({ productId: this.recordId })
            .then(async (centres) => {
                const enrichedCentres = [];

                for (const centre of centres) {
                    try {
                        const price = await getProductPriceInPricebook({
                            productId: this.recordId,
                            pricebookId: centre.Pricebook__c
                        });
                        enrichedCentres.push({ ...centre, price });
                    } catch (err) {
                        this.showToast('Ошибка получения цены', `Не удалось получить цену для центра ${centre.Name}`);
                        enrichedCentres.push({ ...centre, price: null });
                    }
                }

                this.centresWithPrice = enrichedCentres;
            })
            .catch(error => {
                this.showToast('Ошибка загрузки центров', error?.body?.message || error.message);
            });
    }

    get hasCentres() {
        return this.centresWithPrice.length > 0;
    }

    async handleMakeAnAppointment(event) {
        const centreId = event.currentTarget.dataset.id;

        this.selectedProduct = null;
        this.selectedCentre = null;
        this.showModal = false;

        await Promise.resolve(); // reset before modal

        try {
            const product = await getProductById({ productId: this.recordId });

            this.selectedProduct = {
                Id: null,
                Product2Id: product.Id,
                Product2: product,
                UnitPrice: this.centresWithPrice.find(c => c.Id === centreId)?.price || null
            };
            this.selectedCentre = centreId;
            this.showModal = true;
        } catch (error) {
            this.showToast('Ошибка получения процедуры', error?.body?.message || error.message);
        }
    }

    handleModalClose() {
        this.showModal = false;
    }
}