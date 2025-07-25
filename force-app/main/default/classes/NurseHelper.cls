public without sharing class NurseHelper {

    public static List<Account> getNursesByActionCentre(Id centreId) {
        return [
            SELECT Id, Name, Workday_Start__c, Workday_End__c
            FROM Account
            WHERE RecordType.DeveloperName = 'Nurse'
            AND Action_Centre__c = :centreId
        ];
    }
}
