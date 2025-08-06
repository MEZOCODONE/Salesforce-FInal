@isTest
private class ClientHelperTest {

    @isTest
    static void testInsertClient_CreatesLead() {
        Test.startTest();
        Map<String, Id> result = ClientHelper.insertClient(
            'Alice', 'Smith', 'alice@example.com', '111-222-3333'
        );
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Should return one result');
        Assert.isTrue(result.containsKey('Lead'), 'Should return Lead key');

        Id leadId = result.get('Lead');
        Assert.isNotNull(leadId, 'Lead ID should not be null');

        Lead inserted = [SELECT Id, FirstName, Email FROM Lead WHERE Id = :leadId];
        Assert.areEqual('Alice', inserted.FirstName, 'Lead FirstName should match');
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

        Assert.areEqual(1, result.size(), 'Should return one result');
        Assert.isTrue(result.containsKey('Contact'), 'Should return Contact key');
        Assert.areEqual(existing.Id, result.get('Contact'), 'Returned ID should match existing contact');
    }

    @isTest
    static void testInsertClient_MissingFields_ThrowsException() {
        Test.startTest();
        try {
            ClientHelper.insertClient(null, 'Test', 'test@example.com', '1234567890');
            Assert.fail('Expected AuraHandledException for null firstName');
        } catch (AuraHandledException e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Expected specific AuraHandledException message');
        }
        Test.stopTest();
    }
}
