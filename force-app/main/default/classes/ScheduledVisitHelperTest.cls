@isTest
private class ScheduledVisitHelperTest {

    @isTest
    static void testGetVisitTimesByNurse() {
        Account nurse = new Account(Name = 'Nurse A', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        DateTime visit1 = DateTime.newInstance(Date.today(), Time.newInstance(9, 30, 0, 0));
        DateTime visit2 = DateTime.newInstance(Date.today(), Time.newInstance(14, 45, 0, 0));
        DateTime visitOtherDay = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(10, 0, 0, 0));

        insert new List<Scheduled_Visit__c>{
            new Scheduled_Visit__c(Nurse__c = nurse.Id, Appointment_Date__c = visit1),
            new Scheduled_Visit__c(Nurse__c = nurse.Id, Appointment_Date__c = visit2),
            new Scheduled_Visit__c(Nurse__c = nurse.Id, Appointment_Date__c = visitOtherDay)
        };

        Test.startTest();
        List<String> times = ScheduledVisitHelper.getVisitTimesByNurse(nurse.Id, Date.today());
        Test.stopTest();

        Assert.areEqual(2, times.size(), 'Should return only visits for today');
        Assert.isTrue(times.contains('09:30'), 'Returned times should include 09:30');
        Assert.isTrue(times.contains('14:45'), 'Returned times should include 14:45');
    }

    @isTest
    static void testInsertScheduledVisit_Success_Lead() {
        Lead lead = new Lead(LastName = 'Test Lead', Company = 'Test Company');
        insert lead;

        Action_Centre__c centre = new Action_Centre__c(Name = 'Centre A', Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Account nurse = new Account(Name = 'Nurse B', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        Opportunity opp = new Opportunity(Name = 'Opp A', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();
        wrapper.centreId = centre.Id;
        wrapper.nurseId = nurse.Id;
        wrapper.opportunityId = opp.Id;
        wrapper.targetVisitDatetime = DateTime.now();
        wrapper.leadOrContact = new Map<String, Id>{ 'Lead' => lead.Id };

        Test.startTest();
        ScheduledVisitHelper.insertScheduledVisit(wrapper);
        Test.stopTest();

        List<Scheduled_Visit__c> visits = [SELECT Id FROM Scheduled_Visit__c WHERE Procedure_Opportunity__c = :opp.Id];
        Assert.areEqual(1, visits.size(), 'Scheduled visit should be inserted for lead');
    }

    @isTest
    static void testInsertScheduledVisit_Success_Contact() {
        Contact contact = new Contact(LastName = 'Contact Person');
        insert contact;

        Action_Centre__c centre = new Action_Centre__c(Name = 'Centre B', Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Account nurse = new Account(Name = 'Nurse C', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        Opportunity opp = new Opportunity(Name = 'Opp B', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();
        wrapper.centreId = centre.Id;
        wrapper.nurseId = nurse.Id;
        wrapper.opportunityId = opp.Id;
        wrapper.targetVisitDatetime = DateTime.now();
        wrapper.leadOrContact = new Map<String, Id>{ 'Contact' => contact.Id };

        Test.startTest();
        ScheduledVisitHelper.insertScheduledVisit(wrapper);
        Test.stopTest();

        List<Scheduled_Visit__c> visits = [SELECT Id FROM Scheduled_Visit__c WHERE Procedure_Opportunity__c = :opp.Id];
        Assert.areEqual(1, visits.size(), 'Scheduled visit should be inserted for contact');
    }

    @isTest
    static void testInsertScheduledVisit_MissingFields_ShouldThrow() {
        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();
        Test.startTest();
        try {
            ScheduledVisitHelper.insertScheduledVisit(wrapper);
            Assert.fail('Expected AuraHandledException due to missing fields');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception message should indicate script error');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertScheduledVisit_InvalidClientType_ShouldThrow() {
        ScheduledVisitWrapper wrapper = new ScheduledVisitWrapper();
        wrapper.centreId = Id.valueOf('001000000000001');
        wrapper.nurseId = Id.valueOf('001000000000002');
        wrapper.opportunityId = Id.valueOf('006000000000003');
        wrapper.targetVisitDatetime = DateTime.now();
        wrapper.leadOrContact = new Map<String, Id>{ 'Account' => Id.valueOf('001000000000004') };

        Test.startTest();
        try {
            ScheduledVisitHelper.insertScheduledVisit(wrapper);
            Assert.fail('Expected AuraHandledException due to unsupported client type');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception message should indicate script error');
        }
        Test.stopTest();
    }

    private static Id getNurseRecordTypeId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Nurse').getRecordTypeId();
    }
}
