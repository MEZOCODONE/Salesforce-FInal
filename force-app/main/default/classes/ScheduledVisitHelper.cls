public without sharing class ScheduledVisitHelper {

    public static List<String> getVisitTimesByNurse(Id nurseId, Date targetDate) {

        List<Scheduled_Visit__c> allVisits = [ SELECT Id, Appointment_Date__c FROM Scheduled_Visit__c WHERE Nurse__c = :nurseId];

        List<String> resultTimes = new List<String>();

        for (Scheduled_Visit__c v : allVisits) {
            if (v.Appointment_Date__c != null && v.Appointment_Date__c.date() == targetDate) {
                Time t = v.Appointment_Date__c.time();

                String hour = String.valueOf(t.hour()).leftPad(2, '0');
                String minute = String.valueOf(t.minute()).leftPad(2, '0');
                String formattedTime = hour + ':' + minute;

                resultTimes.add(formattedTime);
            }
        }

        return resultTimes;
    }
    public static void insertScheduledVisit(ScheduledVisitWrapper v) {
        if (v == null || v.centreId == null || v.nurseId == null || v.opportunityId == null || v.targetVisitDatetime == null || v.leadOrContact == null || v.leadOrContact.isEmpty())
            throw new AuraHandledException('Missing required ScheduledVisit fields.');
    
        String key = v.leadOrContact.keySet().iterator().next();
        Id clientId = v.leadOrContact.get(key);
        if (clientId == null || (key != 'Lead' && key != 'Contact'))
            throw new AuraHandledException('Invalid client type or missing ID.');
    
        insert new Scheduled_Visit__c(
            Name = 'Visit: ' + v.centreId + ' / ' + v.nurseId + ' @ ' + String.valueOf(v.targetVisitDatetime),
            Action_Centre__c = v.centreId,
            Nurse__c = v.nurseId,
            Procedure_Opportunity__c = v.opportunityId,
            Appointment_Date__c = v.targetVisitDatetime,
            Client__c = key == 'Contact' ? clientId : null,
            Lead__c = key == 'Lead' ? clientId : null
        );
    }

}
