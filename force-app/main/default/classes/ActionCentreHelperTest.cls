@isTest
private class ActionCentreHelperTest {

    @testSetup
    static void setupTestData() {
        Id standardPbId = Test.getStandardPricebookId();

        Pricebook2 customPb = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert customPb;

        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TP001', IsActive = true);
        insert prod;

        PricebookEntry standardEntry = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = prod.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert standardEntry;

        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.0,
            IsActive = true
        );
        insert customEntry;

        insert new List<Action_Centre__c>{
            new Action_Centre__c(Name = 'Alpha Centre', Phone_Number__c = '1234567890', Email__c = 'alpha@test.com', Working_Hours__c = '9am - 5pm', Pricebook__c = customPb.Id),
            new Action_Centre__c(Name = 'Beta Centre', Phone_Number__c = '9876543210', Email__c = 'beta@test.com', Working_Hours__c = '10am - 6pm', Pricebook__c = customPb.Id)
        };
    }

    @isTest
    static void testGetActionCentres() {
        List<Action_Centre__c> centres = ActionCentreHelper.getActionCentres();
        Assert.isTrue(!centres.isEmpty(), 'Should return some action centres');
    }

    @isTest
    static void testSearchCentres() {
        List<Action_Centre__c> result = ActionCentreHelper.searchCentres('Alpha');
        Assert.areEqual(1, result.size(), 'Should find one centre matching "Alpha"');
        Assert.isTrue(result[0].Name.contains('Alpha'), 'Name should contain "Alpha"');
    }

    @isTest
    static void testGetCentreProducts() {
        Action_Centre__c centre = [SELECT Id FROM Action_Centre__c WHERE Name = 'Alpha Centre' LIMIT 1];
        List<PricebookEntry> products = ActionCentreHelper.getCentreProducts(centre.Id);
        Assert.areEqual(1, products.size(), 'Should return one product');
        Assert.areEqual('Test Product', products[0].Product2.Name, 'Product name should match');
    }

    @isTest
    static void testGetCentresByProduct() {
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        Assert.isTrue(!products.isEmpty(), 'Test Product not found');
        Product2 product = products[0];

        List<Action_Centre__c> acList = [SELECT Id FROM Action_Centre__c WHERE Name = 'Beta Centre' LIMIT 1];
        Assert.isTrue(!acList.isEmpty(), 'Test Action Centre not found');

        List<Action_Centre__c> centres = ActionCentreHelper.getCentresByProduct(product.Id);
        Assert.isTrue(!centres.isEmpty(), 'Should return centres with matching product');
    }

    @isTest
    static void testGetCentreById_ValidId() {
        Action_Centre__c centre = [SELECT Id FROM Action_Centre__c WHERE Name = 'Beta Centre' LIMIT 1];
        Action_Centre__c result = ActionCentreHelper.getCentreById(centre.Id);
        Assert.areEqual(centre.Id, result.Id, 'Returned centre should match input ID');
    }

    @isTest
    static void testGetCentreById_InvalidId() {
        Action_Centre__c centre = new Action_Centre__c(
            Name = 'Temp Centre',
            Working_Hours__c = '9am - 5pm'
        );
        insert centre;
        delete centre;

        try {
            ActionCentreHelper.getCentreById(centre.Id);
            Assert.fail('Expected AuraHandledException for deleted ID');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
    }
}
