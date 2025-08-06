@isTest
private class ClientControllerTest {

    @isTest
    static void testInsertClient_Success() {
        Test.startTest();
        ClientController.insertClient('Jane', 'Doe', 'jane.doe@example.com', '123-456-7890');
        Test.stopTest();

        List<Lead> leads = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'jane.doe@example.com'];
        Assert.areEqual(1, leads.size(), 'Lead should be created');
        Assert.areEqual('Jane', leads[0].FirstName, 'Lead FirstName should match');
    }

    @isTest
    static void testInsertClient_MissingFields_ThrowsAuraException() {
        Test.startTest();
        try {
            ClientController.insertClient(null, 'Doe', 'jane.doe@example.com', '123-456-7890');
            Assert.fail('Expected AuraHandledException for missing firstName');
        } catch (AuraHandledException e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName(), 'Expected AuraHandledException type');
        }
        Test.stopTest();
    }
}
