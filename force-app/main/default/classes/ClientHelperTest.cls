@isTest
private class ClientHelperTest {

    @isTest
    static void testInsertClient_CreatesLead() {
        Test.startTest();
        Map<String, Id> result = ClientHelper.insertClient(
            'Alice', 'Smith', 'alice@example.com', '111-222-3333'
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one result');
        System.assert(result.containsKey('Lead'), 'Should return Lead key');
        Id leadId = result.get('Lead');
        System.assertNotEquals(null, leadId, 'Lead ID should not be null');

        Lead inserted = [SELECT Id, FirstName, Email FROM Lead WHERE Id = :leadId];
        System.assertEquals('Alice', inserted.FirstName);
    }

    @isTest
    static void testInsertClient_UsesExistingContact() {
        
        Contact existing = new Contact(
            FirstName = 'Bob',
            LastName = 'Johnson',
            Email = 'bob@example.com',
            Phone = '999-888-7777'
        );
        insert existing;

        Test.startTest();
        Map<String, Id> result = ClientHelper.insertClient(
            'Bob', 'Johnson', 'bob@example.com', '999-888-7777'
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one result');
        System.assert(result.containsKey('Contact'), 'Should return Contact key');
        System.assertEquals(existing.Id, result.get('Contact'), 'Returned ID should match existing contact');
    }

    @isTest
    static void testInsertClient_MissingFields_ThrowsException() {
        Test.startTest();
        try {
            ClientHelper.insertClient(null, 'Test', 'test@example.com', '1234567890');
            System.assert(false, 'Expected AuraHandledException for null firstName');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}