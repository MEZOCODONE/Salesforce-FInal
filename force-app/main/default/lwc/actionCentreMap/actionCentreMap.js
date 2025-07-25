import { LightningElement, wire } from 'lwc';
import getActionCentres from '@salesforce/apex/ActionCentreController.getActionCentres';

export default class ActionCentreMap extends LightningElement {
    mapMarkers = [];
    error;

    @wire(getActionCentres)
    wiredCentres({ error, data }) {
        if (data) {
            this.mapMarkers = data.map(centre => {
                const addr = centre.Address__c;
                const type = centre.RecordType?.Name;

                let description = `📍 ${addr.street}, ${addr.city}\n🕒 ${centre.Working_Hours__c || ''}`;

                if (type === 'Client Support Centre') {
                    description += `\n📞 ${centre.Phone_Number__c || ''}\n✉️ ${centre.Email__c || ''}`;
                }

                return {
                    location: {
                        Street: addr.street,
                        City: addr.city,
                        PostalCode: addr.postalCode,
                        Country: addr.country
                    },
                    title: centre.Name,
                    description,
                    icon: 'standard:account'
                };
            });

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.mapMarkers = [];
        }
    }
}
