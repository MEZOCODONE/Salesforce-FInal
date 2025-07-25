public without sharing class NurseController {

    @AuraEnabled(cacheable = true)
    public static List<Account> getNursesByActionCentre(Id centreId) {
        try {
            return NurseHelper.getNursesByActionCentre(centreId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}