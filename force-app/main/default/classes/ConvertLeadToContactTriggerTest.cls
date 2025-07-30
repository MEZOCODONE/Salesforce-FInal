@isTest
private class ConvertLeadToContactTriggerTest {

    @isTest
    static void testTrigger_LeadConversionViaUpdate() {
        Lead l = new Lead(
            FirstName = 'Trigger',
            LastName = 'Test',
            Email = 'trigger@example.com',
            Phone = '555-1234',
            Company = 'Trigger Co',
            Status = 'Open - Not Contacted'
        );
        insert l;

        Scheduled_Visit__c visit = new Scheduled_Visit__c(
            Name = 'Visit Trigger',
            Lead__c = l.Id,
            Is_Done__c = false
        );
        insert visit;

        visit.Is_Done__c = true;

        Test.startTest();
        update visit;
        Test.stopTest();

        Scheduled_Visit__c updated = [SELECT Id, Lead__c, Client__c FROM Scheduled_Visit__c WHERE Id = :visit.Id];

        System.assertEquals(null, updated.Lead__c, 'Lead__c должен быть очищен триггером');
        System.assertNotEquals(null, updated.Client__c, 'Client__c должен быть заполнен триггером');

        Contact c = [SELECT Id, Email FROM Contact WHERE Id = :updated.Client__c];
        System.assertEquals('trigger@example.com', c.Email);
    }
}