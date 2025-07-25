public without sharing class ProcedureController {

    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllProcedures() {
        try {
            return ProcedureHelper.getAllProcedures();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, ProcedureHelper.ProductInfo> getAllProceduresWithMinimalPrice() {
        try {
            return ProcedureHelper.getAllProceduresWithMinimalPrice();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> searchProcedures(String searchTerm) {
        try {
            return ProcedureHelper.searchProcedures(searchTerm);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(Id productId) {
        try {
            return ProcedureHelper.getProductById(productId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getProductPriceInPricebook(Id productId, Id pricebookId) {
        try {
            return ProcedureHelper.getProductPriceInPricebook(productId, pricebookId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
