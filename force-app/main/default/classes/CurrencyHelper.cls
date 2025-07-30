public with sharing class CurrencyHelper {
    public static Map<String, Decimal> getCurrencyRates() {
        if (CurrencyHelperTestUtil.hasMockRates()) {
            Map<String, Decimal> rates = new Map<String, Decimal>(CurrencyHelperTestUtil.getMockRates());
            rates.put('USD', 1);
            return rates;
        }

        Map<String, Decimal> rates = new Map<String, Decimal>();
        for (CurrencyFromApi__mdt record : [SELECT MasterLabel, Exchange__c FROM CurrencyFromApi__mdt]) {
            rates.put(record.MasterLabel, record.Exchange__c);
        }
        rates.put('USD', 1);
        return rates;
    }
}
