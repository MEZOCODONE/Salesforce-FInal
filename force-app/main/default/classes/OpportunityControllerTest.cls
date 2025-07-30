@isTest
private class OpportunityControllerTest {

    @isTest
    static void testInsertOpportunity_Success() {
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        Id standardPBId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = standardPBId,
            UnitPrice = 123,
            IsActive = true
        );
        insert pbe;

        Action_Centre__c centre = new Action_Centre__c(
            Name = 'Centre Controller Test',
            Pricebook__c = standardPBId,
            Working_Hours__c = '00:00 - 00:00'
        );
        insert centre;

        Test.startTest();
        Opportunity opp = OpportunityController.insertOpportunity(
            'Controller Opp',
            product.Id,
            centre.Id,
            Date.today().addDays(2)
        );
        Test.stopTest();

        System.assertNotEquals(null, opp);
        System.assertEquals('Controller Opp', opp.Name);
    }

    @isTest
    static void testInsertOpportunity_NullInputs_ShouldThrow() {
        Test.startTest();
        try {
            OpportunityController.insertOpportunity(null, null, null, null);
            System.assert(false, 'Expected exception by empty params');
        } catch (AuraHandledException e) {
            System.debug('Caught expected exception: ' + e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertOpportunity_MissingPricebookEntry_ShouldThrow() {
        Product2 product = new Product2(Name = 'Missing Entry Product', IsActive = true);
        insert product;

        Pricebook2 pb = new Pricebook2(Name = 'PB no entry', IsActive = true);
        insert pb;

        Action_Centre__c centre = new Action_Centre__c(
            Name = 'Missing Entry Centre',
            Pricebook__c = pb.Id,
            Working_Hours__c = '00:00 - 00:00'
        );
        insert centre;

        Test.startTest();
        try {
            OpportunityController.insertOpportunity(
                'Bad Opp',
                product.Id,
                centre.Id,
                Date.today().addDays(1)
            );
            System.assert(false, 'Should throw exception');
        } catch (AuraHandledException e) {
            System.debug('Caught expected: ' + e.getMessage());
            System.assert(e.getMessage().startsWith('Script-thrown exception'));
        }
        Test.stopTest();
    }
}
