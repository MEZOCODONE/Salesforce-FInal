public with sharing class CurrencyController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getCurrencyRates() {
        try {
            Map<String, Decimal> rates = CurrencyHelper.getCurrencyRates();
            for (String code : rates.keySet()) {
                if (rates.get(code) <= 0) {
                    throw new AuraHandledException('Invalid currency rate for ' + code);
                }
            }
            return rates;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
