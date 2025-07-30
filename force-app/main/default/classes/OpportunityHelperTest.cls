@isTest
private class OpportunityHelperTest {

    @isTest
    static void testInsertOpportunity_Success() {
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        Id pb = Test.getStandardPricebookId(); 

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = pb,
            UnitPrice = 150,
            IsActive = true
        );
        insert pbe;

        Action_Centre__c centre = new Action_Centre__c(
            Name = 'Centre 1',
            Pricebook__c = pb,
            Working_Hours__c = '00:00 - 00:00'
        );
        insert centre;

        Test.startTest();
        Opportunity opp = OpportunityHelper.insertOpportunity(
            'Test Opp',
            product.Id,
            centre.Id,
            Date.today().addDays(5)
        );
        Test.stopTest();

        System.assertNotEquals(null, opp, 'Opportunity should be returned');
        System.assertEquals('Test Opp', opp.Name);
        System.assertEquals('Prospecting', opp.StageName);
    }

    @isTest
    static void testInsertOpportunity_NullInputs_ShouldThrow() {
        Test.startTest();
        try {
            OpportunityHelper.insertOpportunity(null, null, null, null);
            System.assert(false, 'Should throw AuraHandledException for null input');
        } catch (AuraHandledException e) {
            System.assertEquals(
                'Script-thrown exception',
                e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertOpportunity_MissingPricebookEntry_ShouldThrow() {
        Product2 product = new Product2(Name = 'No Price Product', IsActive = true);
        insert product;

        Pricebook2 pb = new Pricebook2(Name = 'PB without entry', IsActive = true);
        insert pb;

        Action_Centre__c centre = new Action_Centre__c(
            Name = 'Centre 2',
            Pricebook__c = pb.Id,
            Working_Hours__c = '00:00 - 00:00'
        );
        insert centre;

        Test.startTest();
        try {
            OpportunityHelper.insertOpportunity(
                'Opp With Missing Entry',
                product.Id,
                centre.Id,
                Date.today().addDays(3)
            );
            System.assert(false, 'Expected AuraHandledException due to missing PricebookEntry');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().startsWith('Script-thrown exception'), 'Expected wrapped error message');
        }
        Test.stopTest();
    }
}
