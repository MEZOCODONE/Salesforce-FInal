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
        
        System.assertEquals(3, result.size());
        System.assertEquals(1, result.get('USD'));
        System.assertEquals(0.9, result.get('EUR'));
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
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception should be by rates');
        }
        Test.stopTest();
    }

}