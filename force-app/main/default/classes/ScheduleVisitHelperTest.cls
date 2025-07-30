@isTest
private class ScheduleVisitHelperTest {

    @isTest
    static void testInsertEvent_Success() {
        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Procedure Test', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = pricebookId,
            UnitPrice = 120,
            IsActive = true
        );
        insert pbe;

        Account nurse = new Account(Name = 'Nurse X', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        Action_Centre__c centre = new Action_Centre__c(Name = 'Centre X', Pricebook__c = pricebookId, Working_Hours__c = '00:00 - 00:00');
        insert centre;

        ScheduleVisitHelper.ScheduleVisitEventWrapper wrap = new ScheduleVisitHelper.ScheduleVisitEventWrapper();
        wrap.centreId = centre.Id;
        wrap.nurseId = nurse.Id;
        wrap.procedureId = prod.Id;
        wrap.dateStr = String.valueOf(Date.today()); // 'yyyy-MM-dd'
        wrap.timeStr = '10:30';
        wrap.firstName = 'Adam';
        wrap.lastName = 'Smith';
        wrap.email = 'adam@test.com';
        wrap.phone = '123456789';

        Test.startTest();
        ScheduleVisitHelper.insertEvent(wrap);
        Test.stopTest();

        List<Scheduled_Visit__c> visits = [
            SELECT Id, Appointment_Date__c FROM Scheduled_Visit__c WHERE Nurse__c = :nurse.Id
        ];
        System.assertEquals(1, visits.size(), 'Expected a scheduled visit to be created');
    }

    @isTest
    static void testInsertEvent_MissingFields_ShouldThrow() {
        ScheduleVisitHelper.ScheduleVisitEventWrapper wrap = new ScheduleVisitHelper.ScheduleVisitEventWrapper();
        Test.startTest();
        try {
            ScheduleVisitHelper.insertEvent(wrap);
            System.assert(false, 'Exception was expected');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertEvent_DuplicateTimeSlot_ShouldThrow() {
        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Procedure Test', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = pricebookId,
            UnitPrice = 120,
            IsActive = true
        );
        insert pbe;

        Account nurse = new Account(Name = 'Nurse Y', RecordTypeId = getNurseRecordTypeId());
        insert nurse;

        Action_Centre__c centre = new Action_Centre__c(Name = 'Centre Y', Pricebook__c = pricebookId, Working_Hours__c = '00:00 - 00:00');
        insert centre;

        Date dateVal = Date.today();
        String dateStr = String.valueOf(dateVal);
        String timeStr = '14:00';
        Datetime dt = Datetime.valueOf(dateStr + ' ' + timeStr + ':00');

        insert new Scheduled_Visit__c(
            Nurse__c = nurse.Id,
            Appointment_Date__c = dt
        );

        ScheduleVisitHelper.ScheduleVisitEventWrapper wrap = new ScheduleVisitHelper.ScheduleVisitEventWrapper();
        wrap.centreId = centre.Id;
        wrap.nurseId = nurse.Id;
        wrap.procedureId = prod.Id;
        wrap.dateStr = dateStr;
        wrap.timeStr = timeStr;
        wrap.firstName = 'John';
        wrap.lastName = 'Doe';
        wrap.email = 'john@example.com';
        wrap.phone = '987654321';

        Test.startTest();
        try {
            ScheduleVisitHelper.insertEvent(wrap);
            System.assert(false, 'Expected duplicate time exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    private static Id getNurseRecordTypeId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Nurse').getRecordTypeId();
    }
}
