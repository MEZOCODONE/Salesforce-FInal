public class CurrencyHelperTestUtil {
    private static Map<String, Decimal> mockRates;

    public static void setMockRates(Map<String, Decimal> rates) {
        mockRates = rates;
    }

    public static void clearMockRates() {
        mockRates = null;
    }

    public static Map<String, Decimal> getMockRates() {
        return mockRates;
    }

    public static Boolean hasMockRates() {
        return Test.isRunningTest() && mockRates != null;
    }
}
