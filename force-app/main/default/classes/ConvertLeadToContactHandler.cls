public with sharing class ConvertLeadToContactHandler {
    public static void handleBeforeUpdate(List<Scheduled_Visit__c> newList, List<Scheduled_Visit__c> oldList) {
        Set<Id> leadIdsToConvert = new Set<Id>();
        Map<Id, Scheduled_Visit__c> visitByLeadId = new Map<Id, Scheduled_Visit__c>();

        for (Integer i = 0; i < newList.size(); i++) {
            Scheduled_Visit__c newRec = newList[i];
            Scheduled_Visit__c oldRec = oldList[i];

            if (newRec.Is_Done__c == true && oldRec.Is_Done__c != true && newRec.Lead__c != null) {
                leadIdsToConvert.add(newRec.Lead__c);
                visitByLeadId.put(newRec.Lead__c, newRec);
            }
        }

        if (leadIdsToConvert.isEmpty()) return;

        List<Lead> leadsToConvert = [
            SELECT Id, FirstName, LastName, Email, Phone
            FROM Lead
            WHERE Id IN :leadIdsToConvert
        ];

        List<Contact> newContacts = new List<Contact>();
        Map<Id, Id> leadToContactIdMap = new Map<Id, Id>();

        for (Lead l : leadsToConvert) {
            Contact c = new Contact(
                FirstName = l.FirstName,
                LastName = l.LastName,
                Email = l.Email,
                Phone = l.Phone
            );
            newContacts.add(c);
            leadToContactIdMap.put(l.Id, null);
        }

        insert newContacts;

        Integer index = 0;
        for (Id leadId : leadToContactIdMap.keySet()) {
            leadToContactIdMap.put(leadId, newContacts[index++].Id);
        }

        for (Id leadId : leadToContactIdMap.keySet()) {
            Scheduled_Visit__c visit = visitByLeadId.get(leadId);
            visit.Client__c = leadToContactIdMap.get(leadId);
            visit.Lead__c = null;
        }
    }
}
