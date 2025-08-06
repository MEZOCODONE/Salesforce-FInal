@isTest
private class CurrencyHelperTest {

    @isTest
    static void testGetCurrencyRates_WithExistingMetadata() {
        Map<String, Decimal> rates = CurrencyHelper.getCurrencyRates();

        Assert.isTrue(rates.containsKey('USD'), 'USD should be in results');
        Assert.areEqual(1, rates.get('USD'), 'USD rate should be 1');
        Assert.isTrue(rates.size() > 1, 'Expected more than one currency in the result');
    }
}
