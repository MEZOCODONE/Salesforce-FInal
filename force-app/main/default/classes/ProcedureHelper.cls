public without sharing class ProcedureHelper {

    public static List<Product2> getAllProcedures() {
        return [SELECT Id, Name, Description FROM Product2];
    }

    public static Map<Id, ProductInfo> getAllProceduresWithMinimalPrice() {
        List<PricebookEntry> entries = [
            SELECT Product2Id, Product2.Name, Product2.Description, Product2.Id, UnitPrice FROM PricebookEntry
            WHERE IsActive = true AND Pricebook2.IsActive = true AND Product2Id != null];

        Map<Id, Decimal> minPriceByProductId = new Map<Id, Decimal>();

        for (PricebookEntry entry : entries) {
            Id productId = entry.Product2Id;
            Decimal currentPrice = entry.UnitPrice;

            if (!minPriceByProductId.containsKey(productId) || currentPrice < minPriceByProductId.get(productId)) {
                minPriceByProductId.put(productId, currentPrice);
            }
        }

        Map<Id, ProductInfo> result = new Map<Id, ProductInfo>();

        for (PricebookEntry entry : entries) {
            Id productId = entry.Product2.Id;
            Decimal minPrice = minPriceByProductId.get(productId);

            if (!result.containsKey(productId) && entry.UnitPrice == minPrice) {
                Product2 p = entry.Product2;
                result.put(productId, new ProductInfo(p.Id, p.Name, p.Description, minPrice));
            }
        }
        return result;
    }

    public static List<Product2> searchProcedures(String searchTerm) {
        String searchQuery = '%' + searchTerm + '%';
        List<Product2> products = [
            SELECT Id, Name
            FROM Product2
            WHERE Name LIKE :searchQuery
            LIMIT 15
        ];
        return products;
    }

    public static Decimal getProductPriceInPricebook(Id productId, Id pricebookId) {
        PricebookEntry entry = [
            SELECT UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND Product2Id = :productId AND IsActive = true
            LIMIT 1
        ];
        return entry != null ? entry.UnitPrice : null;
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(Id productId) {
        return [ SELECT Id, Name, Description, ProductCode FROM Product2 WHERE Id = :productId LIMIT 1];
    }

    public class ProductPriceWrapper {
        @AuraEnabled public Product2 product;
        @AuraEnabled public Decimal price;

        public ProductPriceWrapper(Product2 product, Decimal price) {
            this.product = product;
            this.price = price;
        }
    }

    public class ProductInfo {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal price;

        public ProductInfo(Id id, String name, String description, Decimal price) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.price = price;
        }
    }
}
