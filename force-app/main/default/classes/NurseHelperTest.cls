@isTest
private class NurseHelperTest {

    @isTest
    static void testGetNursesByActionCentre_Valid() {
        RecordTypeInfo rtInfo = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Nurse');
        Id nurseRTId = rtInfo != null ? rtInfo.getRecordTypeId() : null;

        System.assertNotEquals(null, nurseRTId, 'RecordType "Nurse" not found — check DeveloperName');

        Action_Centre__c centre = new Action_Centre__c(Name = 'Test Centre', Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Account nurse = new Account(
            Name = 'Test Nurse',
            RecordTypeId = nurseRTId,
            Action_Centre__c = centre.Id
        );
        insert nurse;

        Test.startTest();
        List<Account> result = NurseHelper.getNursesByActionCentre(centre.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Nurse not found');
        System.assertEquals(nurse.Id, result[0].Id);
    }

    @isTest
    static void testGetNursesByActionCentre_NullId_ShouldThrow() {
        Test.startTest();
        try {
            NurseHelper.getNursesByActionCentre(null);
            System.assert(false, 'Expected exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception should be by rates');
        }
        Test.stopTest();
    }

}
