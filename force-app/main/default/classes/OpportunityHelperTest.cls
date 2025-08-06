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

        Assert.isNotNull(opp, 'Opportunity should be returned');
        Assert.areEqual('Test Opp', opp.Name, 'Opportunity name should match');
        Assert.areEqual('Prospecting', opp.StageName, 'Opportunity stage should be Prospecting');
    }

    @isTest
    static void testInsertOpportunity_NullInputs_ShouldThrow() {
        Test.startTest();
        try {
            OpportunityHelper.insertOpportunity(null, null, null, null);
            Assert.fail('Expected AuraHandledException for null input');
        } catch (AuraHandledException e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Expected exception message');
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
            Assert.fail('Expected AuraHandledException due to missing PricebookEntry');
        } catch (AuraHandledException e) {
            Assert.isTrue(
                e.getMessage().startsWith('Script-thrown exception'),
                'Expected exception message to start with "Script-thrown exception"'
            );
        }
        Test.stopTest();
    }
}
