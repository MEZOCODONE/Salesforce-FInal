trigger ConvertLeadToContact on Scheduled_Visit__c (before update) {
    Set<Id> leadIdsToConvert = new Set<Id>();
    Map<Id, Scheduled_Visit__c> visitByLeadId = new Map<Id, Scheduled_Visit__c>();

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Scheduled_Visit__c newRec = Trigger.new[i];
        Scheduled_Visit__c oldRec = Trigger.old[i];

        if (newRec.Is_Done__c == true && oldRec.Is_Done__c != true && newRec.Lead__c != null) {
            leadIdsToConvert.add(newRec.Lead__c);
            visitByLeadId.put(newRec.Lead__c, newRec);
        }
    }

    if (!leadIdsToConvert.isEmpty()) {
        List<Lead> leadsToConvert = [SELECT Id, FirstName, LastName, Email, Phone FROM Lead WHERE Id IN :leadIdsToConvert];
        List<Contact> newContacts = new List<Contact>();

        Map<Id, Contact> createdContactsByLeadId = new Map<Id, Contact>();

        for (Lead l : leadsToConvert) {
            Contact c = new Contact(
                FirstName = l.FirstName,
                LastName = l.LastName,
                Email = l.Email,
                Phone = l.Phone
            );
            newContacts.add(c);
            createdContactsByLeadId.put(l.Id, c);
        }

        insert newContacts;

        for (Id leadId : createdContactsByLeadId.keySet()) {
            Contact created = createdContactsByLeadId.get(leadId);
            Scheduled_Visit__c visit = visitByLeadId.get(leadId);

            visit.Client__c = created.Id;
            visit.Lead__c = null;
        }
    }
}
