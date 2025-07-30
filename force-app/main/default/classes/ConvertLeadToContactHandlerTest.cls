@isTest
private class ConvertLeadToContactHandlerTest {

    @isTest
    static void testLeadConversion_Success() {
        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert l;

        Scheduled_Visit__c visit = new Scheduled_Visit__c(
            Name = 'Visit 1',
            Lead__c = l.Id,
            Is_Done__c = false
        );
        insert visit;

        Scheduled_Visit__c oldVisit = visit.clone(false, true, false, false);
        oldVisit.Is_Done__c = false;

        Scheduled_Visit__c updatedVisit = visit.clone(false, true, false, false);
        updatedVisit.Is_Done__c = true;

        List<Scheduled_Visit__c> oldList = new List<Scheduled_Visit__c>{ oldVisit };
        List<Scheduled_Visit__c> newList = new List<Scheduled_Visit__c>{ updatedVisit };

        Test.startTest();
        ConvertLeadToContactHandler.handleBeforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(null, newList[0].Lead__c, 'Lead__c должен быть очищен');
        System.assertNotEquals(null, newList[0].Client__c, 'Client__c должен быть заполнен');

        Contact c = [SELECT Id, Email FROM Contact WHERE Id = :newList[0].Client__c LIMIT 1];
        System.assertEquals('lead@example.com', c.Email);
    }

    @isTest
    static void testNoConversion_IfNotMarkedDone() {
        Lead l = new Lead(
            FirstName = 'Test2',
            LastName = 'Lead2',
            Email = 'lead2@example.com',
            Phone = '9876543210',
            Company = 'Another Co',
            Status = 'Open - Not Contacted'
        );
        insert l;

        Scheduled_Visit__c visit = new Scheduled_Visit__c(
            Name = 'Visit 2',
            Lead__c = l.Id,
            Is_Done__c = false
        );
        insert visit;

        List<Scheduled_Visit__c> oldList = new List<Scheduled_Visit__c>{ visit };
        List<Scheduled_Visit__c> newList = new List<Scheduled_Visit__c>{
            visit.clone(false, true, false, false)
        };

        Test.startTest();
        ConvertLeadToContactHandler.handleBeforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(l.Id, newList[0].Lead__c, 'Lead__c должен остаться');
        System.assertEquals(null, newList[0].Client__c, 'Client__c должен быть пуст');
    }

    @isTest
    static void testMultipleConversions() {
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName='L1', LastName='X', Email='l1@example.com', Phone='111', Company='A', Status='Open - Not Contacted'),
            new Lead(FirstName='L2', LastName='Y', Email='l2@example.com', Phone='222', Company='B', Status='Open - Not Contacted')
        };
        insert leads;

        List<Scheduled_Visit__c> visits = new List<Scheduled_Visit__c>();
        for (Lead l : leads) {
            visits.add(new Scheduled_Visit__c(Name='Visit ' + l.FirstName, Lead__c=l.Id, Is_Done__c=false));
        }
        insert visits;

        List<Scheduled_Visit__c> oldList = new List<Scheduled_Visit__c>();
        List<Scheduled_Visit__c> newList = new List<Scheduled_Visit__c>();
        for (Scheduled_Visit__c v : visits) {
            Scheduled_Visit__c oldV = v.clone(false, true, false, false);
            Scheduled_Visit__c newV = v.clone(false, true, false, false);
            oldV.Is_Done__c = false;
            newV.Is_Done__c = true;

            oldList.add(oldV);
            newList.add(newV);
        }

        Test.startTest();
        ConvertLeadToContactHandler.handleBeforeUpdate(newList, oldList);
        Test.stopTest();

        for (Scheduled_Visit__c v : newList) {
            System.assertEquals(null, v.Lead__c);
            System.assertNotEquals(null, v.Client__c);
        }
    }
}
