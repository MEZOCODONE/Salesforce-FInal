trigger ConvertLeadToContact on Scheduled_Visit__c (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        ConvertLeadToContactHandler.handleBeforeUpdate(Trigger.new, Trigger.old);
    }
}
