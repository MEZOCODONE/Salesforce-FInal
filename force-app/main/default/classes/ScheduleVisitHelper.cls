public without sharing class ScheduleVisitHelper {

    @AuraEnabled
    public static void insertEvent(Id centreId, Id nurseId, Id procedureId, String dateStr, String timeStr, 
                                   String firstName, String lastName, String email, String phone) {
        try {
            Date dateForOpportunity = Date.valueOf(dateStr);

            Opportunity op = OpportunityHelper.insertOpportunity(
                firstName + ' ' + lastName + ' ' + dateStr + ' ' + timeStr,
                procedureId, centreId,
                dateForOpportunity
            );

            Map<String, Id> leadOrContact = ClientHelper.insertClient(firstName, lastName, email, phone);

            String dateTimeString = dateStr + ' ' + timeStr + ':00';
            Datetime dt = Datetime.valueOf(dateTimeString);

            ScheduledVisitController.insertScheduledVisit(centreId, nurseId, op.Id, dt, leadOrContact);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
