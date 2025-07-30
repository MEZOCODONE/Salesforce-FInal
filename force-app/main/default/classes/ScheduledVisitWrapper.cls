public class ScheduledVisitWrapper {
    @AuraEnabled public Id centreId { get; set; }
    @AuraEnabled public Id nurseId { get; set; }
    @AuraEnabled public Id opportunityId { get; set; }
    @AuraEnabled public Datetime targetVisitDatetime { get; set; }
    @AuraEnabled public Map<String, Id> leadOrContact { get; set; }

    public ScheduledVisitWrapper() {
        leadOrContact = new Map<String, Id>();
    }
}