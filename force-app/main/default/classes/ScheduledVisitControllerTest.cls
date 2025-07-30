@isTest
private class ScheduledVisitControllerTest {

    @isTest
    static void testGetVisitTimesByNurse_Success() {
        Account nurse = new Account(Name = 'Nurse A', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        DateTime dt = DateTime.newInstance(Date.today(), Time.newInstance(10, 15, 0, 0));

        insert new Scheduled_Visit__c(
            Nurse__c = nurse.Id,
            Appointment_Date__c = dt
        );

        Test.startTest();
        List<String> times = ScheduledVisitController.getVisitTimesByNurse(nurse.Id, Date.today());
        Test.stopTest();

        System.assertEquals(1, times.size());
        System.assertEquals('10:15', times[0]);
    }

    @isTest
    static void testInsertScheduledVisit_Success() {
        Lead lead = new Lead(LastName = 'Lead One', Company = 'Company');
        insert lead;

        Account nurse = new Account(Name = 'Nurse B', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        Action_Centre__c centre = new Action_Centre__c(Name = 'Centre', Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Opportunity opp = new Opportunity(Name = 'Opp', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();
        wrapper.centreId = centre.Id;
        wrapper.nurseId = nurse.Id;
        wrapper.opportunityId = opp.Id;
        wrapper.targetVisitDatetime = DateTime.now();
        wrapper.leadOrContact = new Map<String, Id>{ 'Lead' => lead.Id };

        Test.startTest();
        ScheduledVisitController.insertScheduledVisit(wrapper);
        Test.stopTest();

        List<Scheduled_Visit__c> visits = [
            SELECT Id FROM Scheduled_Visit__c WHERE Procedure_Opportunity__c = :opp.Id
        ];
        System.assertEquals(1, visits.size());
    }

    @isTest
    static void testInsertScheduledVisit_Invalid_ShouldThrow() {
        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();

        Test.startTest();
        try {
            ScheduledVisitController.insertScheduledVisit(wrapper);
            System.assert(false, 'Expected AuraHandledException');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    private static Id getNurseRecordTypeId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Nurse').getRecordTypeId();
    }
}
