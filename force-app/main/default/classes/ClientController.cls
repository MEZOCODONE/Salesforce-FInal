public with sharing class ClientController {

    public static Map<String, Id> insertClient(String firstName, String lastName, String email, String phone){
        try{
            return ClientHelper.insertClient(firstName, lastName, email, phone);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}