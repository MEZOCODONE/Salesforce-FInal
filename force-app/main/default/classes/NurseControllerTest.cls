@isTest
private class NurseControllerTest {

    @isTest
    static void testGetNursesByActionCentre_Valid() {
        Id nurseRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Nurse').getRecordTypeId();

        Action_Centre__c centre = new Action_Centre__c(Name = 'Test Centre', Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Account nurse = new Account(
            Name = 'Test Nurse',
            RecordTypeId = nurseRTId,
            Action_Centre__c = centre.Id
        );
        insert nurse;

        Test.startTest();
        List<Account> nurses = NurseController.getNursesByActionCentre(centre.Id);
        Test.stopTest();

        Assert.areEqual(1, nurses.size(), 'Expected 1 nurse returned');
        Assert.areEqual(nurse.Id, nurses[0].Id, 'Returned nurse should match inserted one');
    }

    @isTest
    static void testGetNursesByActionCentre_Null_ShouldThrow() {
        Test.startTest();
        try {
            NurseController.getNursesByActionCentre(null);
            Assert.fail('Expected AuraHandledException for null centreId');
        } catch (AuraHandledException e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Expected specific exception message');
        }
        Test.stopTest();
    }
}
