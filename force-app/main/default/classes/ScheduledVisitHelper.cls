public without sharing class ScheduledVisitHelper {

    public static List<String> getVisitTimesByNurse(Id nurseId, Date targetDate) {
        System.debug('📛 Запрос визитов для медсестры: ' + nurseId);
        System.debug('📅 Целевая дата: ' + targetDate);

        List<Scheduled_Visit__c> allVisits = [
            SELECT Id, Appointment_Date__c
            FROM Scheduled_Visit__c
            WHERE Nurse__c = :nurseId
        ];

        List<String> resultTimes = new List<String>();

        for (Scheduled_Visit__c v : allVisits) {
            if (v.Appointment_Date__c != null && v.Appointment_Date__c.date() == targetDate) {
                Time t = v.Appointment_Date__c.time();

                String hour = String.valueOf(t.hour()).leftPad(2, '0');
                String minute = String.valueOf(t.minute()).leftPad(2, '0');
                String formattedTime = hour + ':' + minute;

                System.debug('⏰ Визит в ' + formattedTime);
                resultTimes.add(formattedTime);
            }
        }

        System.debug('✅ Занятые часы: ' + resultTimes);
        return resultTimes;
    }

    public static void insertScheduledVisit(
        Id centreId,
        Id nurseId,
        Id Opportunity,
        Datetime targetVisitDatetime,
        Map<String, Id> leadOrContact
    ) {
        String key = leadOrContact.keySet().isEmpty() ? null : leadOrContact.keySet().iterator().next();

        String name = 'Visit: ' + centreId + ' / ' + nurseId + ' @ ' + String.valueOf(targetVisitDatetime);
        switch on key {
            when 'Contact' {
                insert new Scheduled_Visit__c(
                    Name = name,
                    Action_Centre__c = centreId,
                    Nurse__c = nurseId,
                    Client__c = leadOrContact.get('Contact'),
                    Procedure_Opportunity__c = Opportunity,
                    Appointment_Date__c = targetVisitDatetime
                );
            }   
            when 'Lead' {
                insert new Scheduled_Visit__c(
                    Name = name,
                    Action_Centre__c = centreId,
                    Nurse__c = nurseId,
                    Lead__c = leadOrContact.get('Lead'),
                    Procedure_Opportunity__c = Opportunity,
                    Appointment_Date__c = targetVisitDatetime
                );
            }   
            when else {
                throw new AuraHandledException('Unknown client type: nor a Lead or a Contact');
            }
        }
    }
}
