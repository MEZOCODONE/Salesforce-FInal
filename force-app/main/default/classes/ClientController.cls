public with sharing class ClientController {

    public void insertClient(String firstName, String lastName, String email, String phone){
        try{
            ClientHelper.insertClient(firstName, lastName, email, phone);
        }
        throw new AuraHandledException(e.getMessage());
    }
}