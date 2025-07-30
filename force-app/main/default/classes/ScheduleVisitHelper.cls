public without sharing class ScheduleVisitHelper {

@AuraEnabled
public static void insertEvent(ScheduleVisitEventWrapper d) {
    if (d == null || d.centreId == null || d.nurseId == null || d.procedureId == null ||
        String.isBlank(d.dateStr) || String.isBlank(d.timeStr) ||
        String.isBlank(d.firstName) || String.isBlank(d.lastName) ||
        String.isBlank(d.email) || String.isBlank(d.phone)) {
        throw new AuraHandledException('All fields are required to schedule a visit.');
    }

    try {
        Date dateVal = Date.valueOf(d.dateStr);
        String dateTimeStr = d.dateStr + ' ' + d.timeStr + ':00';
        Datetime dt = Datetime.valueOf(dateTimeStr);

        List<Scheduled_Visit__c> existingVisits = [SELECT Id FROM Scheduled_Visit__c WHERE Nurse__c = :d.nurseId AND Appointment_Date__c = :dt 
        LIMIT 1];

        if (!existingVisits.isEmpty()) {
            throw new AuraHandledException('This time slot is already booked for the selected nurse.');
        }

        Opportunity opp = OpportunityHelper.insertOpportunity(
            d.firstName + ' ' + d.lastName + ' ' + d.dateStr + ' ' + d.timeStr,
            d.procedureId, d.centreId, dateVal
        );

        Map<String, Id> client = ClientController.insertClient(d.firstName, d.lastName, d.email, d.phone);

        ScheduledVisitWrapper w = new ScheduledVisitWrapper();
        w.centreId = d.centreId;
        w.nurseId = d.nurseId;
        w.opportunityId = opp.Id;
        w.targetVisitDatetime = dt;
        w.leadOrContact = client;

        ScheduledVisitController.insertScheduledVisit(w);
    } catch (AuraHandledException ae) {
        throw ae;
    } catch (Exception e) {
        throw new AuraHandledException('Error scheduling visit: ' + e.getMessage());
    }
}


    public class ScheduleVisitEventWrapper {
        @AuraEnabled public Id centreId { get; set; }
        @AuraEnabled public Id nurseId { get; set; }
        @AuraEnabled public Id procedureId { get; set; }
        @AuraEnabled public String dateStr { get; set; }
        @AuraEnabled public String timeStr { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
    }
}
