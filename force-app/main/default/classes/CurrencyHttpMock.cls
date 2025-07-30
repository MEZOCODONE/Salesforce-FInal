@isTest
global class CurrencyHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        // Пример фиктивного ответа от API
        res.setBody('{"Cur_OfficialRate": 3.0, "Cur_Scale": 1}');
        return res;
    }
}