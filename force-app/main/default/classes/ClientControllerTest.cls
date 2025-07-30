@isTest
private class ClientControllerTest {

    @isTest
    static void testInsertClient_Success() {
        Test.startTest();
        ClientController.insertClient('Jane', 'Doe', 'jane.doe@example.com', '123-456-7890');
        Test.stopTest();

        // Проверим, что Lead действительно создался
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'jane.doe@example.com'];
        System.assertEquals(1, leads.size(), 'Lead should be created');
        System.assertEquals('Jane', leads[0].FirstName);
    }

    @isTest
    static void testInsertClient_MissingFields_ThrowsAuraException() {

        Test.startTest();
        try {
            ClientController.insertClient(null, 'Doe', 'jane.doe@example.com', '123-456-7890');
            System.assert(false, 'Expected AuraHandledException for missing firstName');
        } catch (AuraHandledException e) {
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
        Test.stopTest();
    }
}
