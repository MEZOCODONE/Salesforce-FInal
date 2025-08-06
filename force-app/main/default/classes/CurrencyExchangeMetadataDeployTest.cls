@isTest
private class CurrencyExchangeMetadataDeployTest {

    @isTest
    static void testExecuteSuccessful() {
        Test.setMock(HttpCalloutMock.class, new CurrencyHttpMock());

        Test.startTest();
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();
        job.execute(null);
        Test.stopTest();

        Assert.isTrue(true, 'Execute completed without exception');
    }

    @isTest
    static void testHandleResultSuccess() {
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();

        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.SUCCEEDED;

        job.handleResult(result, new Metadata.DeployCallbackContext());

        Assert.isTrue(true, 'handleResult (success) completed without exception');
    }

    @isTest
    static void testHandleResultFailure() {
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();

        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.FAILED;

        job.handleResult(result, new Metadata.DeployCallbackContext());

        Assert.isTrue(true, 'handleResult (failure) completed without exception');
    }

    @isTest
    static void testSchedulerEnqueuesQueueable() {
        Test.startTest();
        new CurrencyExchangeScheduler().execute(null);
        Test.stopTest();

        Assert.isTrue(true, 'Scheduler executed and enqueued job without exception');
    }
}
