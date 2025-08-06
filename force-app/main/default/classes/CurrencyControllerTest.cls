@isTest
private class CurrencyControllerTest {
    
    @isTest
    static void testGetCurrencyRates_ValidRates() {
        Test.startTest();
        CurrencyHelperTestUtil.setMockRates(new Map<String, Decimal>{
            'EUR' => 0.9,
            'BYN' => 3.0
        });
        Map<String, Decimal> result = CurrencyController.getCurrencyRates();
        Test.stopTest();
        
        Assert.areEqual(3, result.size(), 'Should return 3 currency entries including USD');
        Assert.areEqual(1, result.get('USD'), 'USD rate should be 1');
        Assert.areEqual(0.9, result.get('EUR'), 'EUR rate should be 0.9');
    }

    @isTest
    static void testGetCurrencyRates_InvalidRate_ShouldThrow() {
        CurrencyHelperTestUtil.setMockRates(new Map<String, Decimal>{
            'USD' => 0, 
            'EUR' => -1.0,
            'BYN' => 2.0
        });

        Test.startTest();
        try {
            CurrencyController.getCurrencyRates();
            Assert.fail('Expected exception was not thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(
                e.getMessage().contains('Script-thrown exception'),
                'Exception message should indicate a script-thrown error due to invalid rates'
            );
        }
        Test.stopTest();
    }
}
