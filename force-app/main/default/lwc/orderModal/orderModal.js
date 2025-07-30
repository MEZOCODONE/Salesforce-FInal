import { LightningElement, api, wire } from 'lwc';
import getNursesByActionCentre from '@salesforce/apex/NurseController.getNursesByActionCentre';
import getVisitsByNurse from '@salesforce/apex/ScheduledVisitController.getVisitTimesByNurse';
import insertEvent from '@salesforce/apex/ScheduleVisitHelper.insertEvent';
import { MessageContext, publish } from 'lightning/messageService';
import TOAST_SERVICE_CHANNEL from '@salesforce/messageChannel/ToastService__c';

export default class OrderModal extends LightningElement {
    @api product;
    @api centreId;
    @api visible = false;

    firstName;
    lastName;
    phone;
    email;

    nurses = [];
    selectedNurse;
    selectedDate;
    today = new Date().toISOString().split('T')[0];

    availableHours = [];
    selectedTime;

    @wire(MessageContext)
    messageContext;

    showToast(title, message, variant = 'error') {
        publish(this.messageContext, TOAST_SERVICE_CHANNEL, {
            title,
            message,
            variant
        });
    }

    renderedCallback() {
        if (this.visible && this.nurses.length === 0 && this.centreId) {
            getNursesByActionCentre({ centreId: this.centreId })
                .then(data => {
                    this.nurses = data;
                    this.selectedDate = null;
                })
                .catch(error => {
                    this.showToast('Error loading nurses', error?.body?.message || error.message);
                });
        }
    }

    get nurseOptions() {
        return this.nurses.map(n => ({
            label: n.Name,
            value: n.Id
        }));
    }

    handleNurseChange(event) {
        const selectedId = event.target.value;
        this.selectedNurse = this.nurses.find(n => n.Id === selectedId);

        if (this.selectedDate) {
            this.fetchVisitsAndGenerateSlots();
        }
    }

    handleClose() {
        this.resetFormFields();
        this.dispatchEvent(new CustomEvent('close'));
        this.visible = false;
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
        if (this.selectedNurse) {
            this.fetchVisitsAndGenerateSlots();
        }
    }

    fetchVisitsAndGenerateSlots() {
        getVisitsByNurse({
            nurseId: this.selectedNurse.Id,
            targetDate: this.selectedDate
        })
            .then(visits => {
                const busyHours = visits.map(v => {
                    const [hourStr] = v.split(':');
                    return parseInt(hourStr, 10);
                });

                const startHour = this.selectedNurse.Workday_Start__c / (1000 * 60 * 60);
                const endHour = this.selectedNurse.Workday_End__c / (1000 * 60 * 60);
                const availableHours = [];

                for (let h = startHour; h < endHour; h++) {
                    if (!busyHours.includes(h)) {
                        availableHours.push(`${h.toString().padStart(2, '0')}:00`);
                    }
                }

                this.availableHours = availableHours;
                this.selectedTime = null;
            })
            .catch(error => {
                this.showToast('Error loading time slots', error?.body?.message || error.message);
            });
    }

    get timeOptions() {
        return this.availableHours.map(h => ({ label: h, value: h }));
    }

    handleTimeChange(event) {
        this.selectedTime = event.target.value;
    }

    handleConfirm() {
        const allInputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
        let isValid = true;

        allInputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.showToast('Validation Error', 'Please complete all required fields.', 'warning');
            return;
        }

        const payload = {
            centreId: this.centreId,
            nurseId: this.selectedNurse?.Id,
            procedureId: this.product?.Product2Id,
            dateStr: this.selectedDate,
            timeStr: this.selectedTime,
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            phone: this.phone
        };

            console.log('--- Final Payload ---');
            console.log(JSON.stringify(payload, null, 2));

        insertEvent({ d: payload })
            .then(() => {
                this.resetFormFields();
                this.dispatchEvent(new CustomEvent('close'));
                this.showToast('Success', 'Appointment successfully scheduled', 'success');
            })
            .catch(error => {
                const message = error?.body?.message || error.message || 'Unknown error';
                this.showToast('Error scheduling appointment', message);

                if (error?.body?.fieldErrors) {
                    Object.entries(error.body.fieldErrors).forEach(([field, errors]) => {
                        errors.forEach(e => {
                            this.showToast(`Field Error: ${field}`, e.message);
                        });
                    });
                }

                if (error?.body?.pageErrors?.length) {
                    error.body.pageErrors.forEach(e => {
                        this.showToast('Page Error', e.message);
                    });
                }
            });
    }


    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value.trim();
    }

    resetFormFields() {
        this.firstName = '';
        this.lastName = '';
        this.phone = '';
        this.email = '';
        this.selectedDate = null;
        this.selectedTime = null;
        this.selectedNurse = null;
    }
}
