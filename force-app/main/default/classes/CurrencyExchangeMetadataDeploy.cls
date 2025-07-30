public without sharing class CurrencyExchangeMetadataDeploy implements Metadata.DeployCallback, Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        Decimal usdRate = 1;
        Decimal eurRate = fetchRate('EUR');
        Decimal bynRate = fetchRate('USD');

        if (eurRate == null || bynRate == null) {
            return;
        }

        Map<String, Decimal> rates = new Map<String, Decimal>{
            'USD' => usdRate,
            'EUR' => bynRate / eurRate,
            'BYN' => bynRate
        };

        deployRatesToMetadata(rates);
    }

    private Decimal fetchRate(String currencyCode) {
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.CurrencyApiUrl + currencyCode + '?parammode=2');
            req.setMethod('GET');

            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Decimal official = (Decimal) result.get('Cur_OfficialRate');
                Decimal scale = (Decimal) result.get('Cur_Scale');
                return official / scale;
            }
        } catch (Exception e) {
        }
        return null;
    }

    private void deployRatesToMetadata(Map<String, Decimal> rates) {
    Metadata.DeployContainer container = new Metadata.DeployContainer();

    for (String currencyCode : rates.keySet()) {
        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();
        cmd.fullName = 'CurrencyFromApi.' + currencyCode;
        cmd.label = currencyCode;

        Metadata.CustomMetadataValue rateValue = new Metadata.CustomMetadataValue();
        rateValue.field = 'Exchange__c';
        rateValue.value = rates.get(currencyCode);
        cmd.values.add(rateValue);

        container.addMetadata(cmd);
    }

    try {
        Id jobId = Metadata.Operations.enqueueDeployment(container, this);
        System.debug('Metadata deployment job enqueued. Job ID: ' + jobId);
    } catch (Exception e) {
        System.debug('Failed to enqueue metadata deployment: ' + e.getMessage());
    }
}

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.SUCCEEDED) {
            System.debug('Deployment succeeded');
        } else {
            System.debug('Deployment failed: ' + result);
        }
    }
}
