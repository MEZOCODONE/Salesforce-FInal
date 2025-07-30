@isTest
private class CurrencyHelperTest {

    @isTest
    static void testGetCurrencyRates_WithExistingMetadata() {
        Map<String, Decimal> rates = CurrencyHelper.getCurrencyRates();

        System.assert(rates.containsKey('USD'), 'USD should be in results');
        System.assertEquals(1, rates.get('USD'));

        System.assert(rates.size() > 1, 'Expected other currencies');
    }
}