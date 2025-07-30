public without sharing class ActionCentreHelper {

    public static List<Action_Centre__c> getActionCentres() {
        List<Action_Centre__c> centres = [SELECT Id, Name, Address__c, Phone_Number__c, Email__c, Working_Hours__c, RecordType.Name 
        FROM Action_Centre__c];
        if(centres.isEmpty()){
            throw new AuraHandledException('No centres found');
        }
        return centres;
    }

    public static List<Action_Centre__c> searchCentres(String searchTerm) {
        String searchQuery = '%' + searchTerm + '%';

        List<Action_Centre__c> centres = [SELECT Id, Name, Address__c, Phone_Number__c, Email__c, Working_Hours__c, RecordType.Name 
        FROM Action_Centre__c WHERE Name LIKE :searchQuery LIMIT 15];
        return centres;
    }

    public static List<PricebookEntry> getCentreProducts(Id centreId) {
        Action_Centre__c centre = [SELECT Id, Name, Pricebook__c FROM Action_Centre__c WHERE Id = :centreId LIMIT 1];
        if (centre.Pricebook__c == null) {
            return new List<PricebookEntry>();
        }
        return [
            SELECT Id, UnitPrice, Product2.Id, Product2.Name, Product2.Description, Product2.ProductCode FROM PricebookEntry 
            WHERE Pricebook2Id = :centre.Pricebook__c AND IsActive = true];
    }

    public static List<Action_Centre__c> getCentresByProduct(Id productId) {
        Set<Id> pricebookIds = new Set<Id>();
        for (PricebookEntry entry : [SELECT Pricebook2Id FROM PricebookEntry WHERE Product2Id = :productId AND IsActive = true]) {
            pricebookIds.add(entry.Pricebook2Id);
        }

        if (pricebookIds.isEmpty()) {
            throw new AuraHandledException('No centres available for this product');
        }
        
        return [SELECT Id, Name, Address__c, Working_Hours__c, Pricebook__c FROM Action_Centre__c WHERE Pricebook__c IN :pricebookIds];
    }

    public static Action_Centre__c getCentreById(Id centreId){
        List<Action_Centre__c> centres = [SELECT Id, Name, Address__c, Phone_Number__c, Email__c, Working_Hours__c, RecordType.Name FROM Action_Centre__c WHERE Id = :centreId LIMIT 1];
        if(centres.isEmpty()){
            throw new AuraHandledException('Centre not found');
        } else {
            return centres.get(0);
        }
    }
}
