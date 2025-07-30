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

        System.assertEquals(1, nurses.size(), 'Expected a nurse');
        System.assertEquals(nurse.Id, nurses[0].Id);
    }

    @isTest
    static void testGetNursesByActionCentre_Null_ShouldThrow() {
        Test.startTest();
        try {
            NurseController.getNursesByActionCentre(null);
            System.assert(false, 'Expecred exception by null centreId');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
}
