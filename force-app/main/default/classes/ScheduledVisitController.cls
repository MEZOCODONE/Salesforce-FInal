/**
 * @description Controller class responsible for handling Scheduled Visit related logic exposed to Lightning/Apex.
 * Delegates the actual logic to the ScheduledVisitHelper class.
 */
public without sharing class ScheduledVisitController {

    /** Empty constructor */
    public ScheduledVisitController() {}

    /**
     * @description Retrieves the list of time slots (in HH:mm format) for a nurse on a specific date.
     *
     * @param nurseId The ID of the nurse (Account).
     * @param targetDate The target date to check scheduled visits for.
     * @return A list of strings representing already scheduled visit times (e.g., '14:00', '15:00').
     * @throws AuraHandledException If the helper method fails.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getVisitTimesByNurse(Id nurseId, Date targetDate) {
        try {
            return ScheduledVisitHelper.getVisitTimesByNurse(nurseId, targetDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void insertScheduledVisit(
        Id centreId,
        Id nurseId,
        Id Opportunity,
        Datetime targetVisitDatetime,
        Map<String, Id> leadOrContact
    ) {
        try {
            ScheduledVisitHelper.insertScheduledVisit(centreId, nurseId, Opportunity, targetVisitDatetime, leadOrContact);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
