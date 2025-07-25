public without sharing class ActionCentreController {

    @AuraEnabled(cacheable=true)
    public static List<Action_Centre__c> getActionCentres() {
        try {
            return ActionCentreHelper.getActionCentres();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Action_Centre__c> searchCentres(String searchTerm) {
        try {
            return ActionCentreHelper.searchCentres(searchTerm);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getCentreProducts(Id centreId) {
        try {
            return ActionCentreHelper.getCentreProducts(centreId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Action_Centre__c> getCentresByProduct(Id productId) {
        try {
            return ActionCentreHelper.getCentresByProduct(productId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Action_Centre__c getCentreById(Id centreId){
        try{
            return ActionCentreHelper.getCentreById(centreId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}
