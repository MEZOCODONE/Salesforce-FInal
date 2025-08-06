public without sharing class CentreProcedurePdfController {

    public class ProcedureWrapper {
        public String Name { get; set; }
        public Decimal ConvertedPrice { get; set; }

        public ProcedureWrapper(String name, Decimal price) {
            this.Name = name;
            this.ConvertedPrice = price;
        }
    }

    public String selectedCurrency { get; set; }
    public String centreName { get; set; }
    public List<ProcedureWrapper> procedures { get; set; }

    public CentreProcedurePdfController() {
        Id centreId = ApexPages.currentPage().getParameters().get('centreId');
        selectedCurrency = ApexPages.currentPage().getParameters().get('currency');

        if (String.isBlank(selectedCurrency)) {
            selectedCurrency = 'USD';
        }

        procedures = new List<ProcedureWrapper>();
        if (centreId == null) return;

        Decimal rate = getCurrencyRate(selectedCurrency);

        Action_Centre__c centre = [
            SELECT Id, Name, Pricebook__c FROM Action_Centre__c WHERE Id = :centreId LIMIT 1
        ];

        centreName = centre.Name;

        List<PricebookEntry> entries = [
            SELECT UnitPrice, Product2.Name
            FROM PricebookEntry
            WHERE Pricebook2Id = :centre.Pricebook__c AND IsActive = true
        ];

        for (PricebookEntry entry : entries) {
            procedures.add(new ProcedureWrapper(
                entry.Product2.Name,
                (entry.UnitPrice * rate).setScale(2)
            ));
        }
    }

    private Decimal getCurrencyRate(String currencyCode) {
        if (currencyCode == 'USD') return 1;

        CurrencyFromApi__mdt record = [
            SELECT Exchange__c FROM CurrencyFromApi__mdt WHERE DeveloperName = :currencyCode LIMIT 1
        ];

        return record.Exchange__c;
    }
}
