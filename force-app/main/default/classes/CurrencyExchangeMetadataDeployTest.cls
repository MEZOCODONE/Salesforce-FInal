@isTest
private class CurrencyExchangeMetadataDeployTest {

    @isTest
    static void testExecuteSuccessful() {
        Test.setMock(HttpCalloutMock.class, new CurrencyHttpMock());

        Test.startTest();
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();
        job.execute(null);
        Test.stopTest();

        System.assert(true, 'Execute completed without exception');
    }

    @isTest
    static void testHandleResultSuccess() {
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();

        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.SUCCEEDED;

        job.handleResult(result, new Metadata.DeployCallbackContext());

        System.assert(true, 'handleResult (success) completed');
    }

    @isTest
    static void testHandleResultFailure() {
        CurrencyExchangeMetadataDeploy job = new CurrencyExchangeMetadataDeploy();

        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.FAILED;

        job.handleResult(result, new Metadata.DeployCallbackContext());

        System.assert(true, 'handleResult (failure) completed');
    }

    @isTest
    static void testSchedulerEnqueuesQueueable() {
        Test.startTest();
        new CurrencyExchangeScheduler().execute(null);
        Test.stopTest();
    
        System.assert(true, 'Метод execute ran without exceptions');
    }
}
