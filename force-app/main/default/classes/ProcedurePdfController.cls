public without sharing class ProcedurePdfController {

    public class ProcedureWrapper {
        public String Name { get; set; }
        public Decimal ConvertedPrice { get; set; }

        public ProcedureWrapper(String name, Decimal price) {
            this.Name = name;
            this.ConvertedPrice = price;
        }
    }

    public String selectedCurrency { get; set; }

    public List<ProcedureWrapper> procedures { get; set; }

    public ProcedurePdfController() {
        selectedCurrency = ApexPages.currentPage().getParameters().get('currency');
        if (String.isBlank(selectedCurrency)) {
            selectedCurrency = 'USD';
        }

        Decimal rate = getCurrencyRate(selectedCurrency);

        Map<Id, ProcedureHelper.ProductInfo> productMap = ProcedureController.getAllProceduresWithMinimalPrice();
        procedures = new List<ProcedureWrapper>();

        for (Id productId : productMap.keySet()) {
            ProcedureHelper.ProductInfo info = productMap.get(productId);
            procedures.add(new ProcedureWrapper(info.name, (info.price * rate).setScale(2)));
        }
    }

    private Decimal getCurrencyRate(String currencyCode) {
        if (currencyCode == 'USD') return 1;
        if (currencyCode == 'EUR') return 0.85;
        if (currencyCode == 'BYN') return 3.3;
        return 1;
    }
}
