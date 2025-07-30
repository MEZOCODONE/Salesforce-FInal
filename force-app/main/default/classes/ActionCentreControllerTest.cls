@isTest
private class ActionCentreControllerTest {

    @testSetup
    static void setupTestData() {
        Id standardPbId = Test.getStandardPricebookId();

        Pricebook2 customPb = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert customPb;

        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TP001', IsActive = true);
        insert prod;

        insert new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = prod.Id,
            UnitPrice = 100.0,
            IsActive = true
        );

        insert new PricebookEntry(
            Pricebook2Id = customPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.0,
            IsActive = true
        );

        insert new List<Action_Centre__c>{
            new Action_Centre__c(
                Name = 'Alpha Centre',
                Phone_Number__c = '1234567890',
                Email__c = 'alpha@test.com',
                Working_Hours__c = '9am - 5pm',
                Pricebook__c = customPb.Id
            ),
            new Action_Centre__c(
                Name = 'Beta Centre',
                Phone_Number__c = '9876543210',
                Email__c = 'beta@test.com',
                Working_Hours__c = '10am - 6pm',
                Pricebook__c = customPb.Id
            )
        };
    }

    @isTest
    static void testGetActionCentres_Success() {
        List<Action_Centre__c> centres = ActionCentreController.getActionCentres();
        System.assertEquals(2, centres.size());
    }

@isTest
static void testGetActionCentres_Exception() {
    delete [SELECT Id FROM Action_Centre__c];
    try {
        ActionCentreController.getActionCentres();
        System.assert(false, 'Expected AuraHandledException');
    } catch (AuraHandledException e) {
        System.assertEquals('System.AuraHandledException', e.getTypeName());
    }
}


    @isTest
    static void testSearchCentres_Success() {
        List<Action_Centre__c> result = ActionCentreController.searchCentres('Alpha');
        System.assertEquals(1, result.size());
    }

    @isTest
    static void testGetCentreProducts_Success() {
        Id centreId = [SELECT Id FROM Action_Centre__c LIMIT 1].Id;
        List<PricebookEntry> result = ActionCentreController.getCentreProducts(centreId);
        System.assertEquals(1, result.size());
    }

    @isTest
    static void testGetCentreProducts_Exception() {
        try {
            ActionCentreController.getCentreProducts(null);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }

    @isTest
    static void testGetCentresByProduct_Success() {
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1].Id;
        List<Action_Centre__c> result = ActionCentreController.getCentresByProduct(productId);
        System.assertEquals(2, result.size());
    }

    @isTest
    static void testGetCentresByProduct_Exception() {
        try {
            ActionCentreController.getCentresByProduct(null);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }

    @isTest
    static void testGetCentreById_Success() {
        Id centreId = [SELECT Id FROM Action_Centre__c WHERE Name = 'Alpha Centre' LIMIT 1].Id;
        Action_Centre__c result = ActionCentreController.getCentreById(centreId);
        System.assertEquals(centreId, result.Id);
    }

    @isTest
    static void testGetCentreById_Exception() {
        Action_Centre__c centre = new Action_Centre__c(
            Name = 'To Delete',
            Phone_Number__c = '0000000000',
            Email__c = 'delete@test.com',
            Working_Hours__c = '00:00 - 00:00'
        );
        insert centre;
        delete centre;

        try {
            ActionCentreController.getCentreById(centre.Id);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}
