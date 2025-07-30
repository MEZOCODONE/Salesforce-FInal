public class CurrencyExchangeScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new CurrencyExchangeMetadataDeploy());
    }
}
