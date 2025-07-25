public without sharing class ClientHelper {

    public static Map<String, Id> insertClient(String firstName, String lastName, String email, String phone) {
        Map<String, Id> newMap = new Map<String, Id>();

        List<Contact> existing = [
            SELECT Id 
            FROM Contact 
            WHERE FirstName = :firstName 
              AND LastName = :lastName 
              AND Email = :email 
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            newMap.put('Contact', existing.get(0).Id);
            return newMap;
        } else {
            Lead newClient = new Lead(
                FirstName = firstName, 
                LastName = lastName, 
                Email = email, 
                Phone = phone, 
                Company = 'New Client', 
                Status = 'Open - Not Contacted'
            );
            insert newClient;
            newMap.put('Lead', newClient.Id);
            return newMap;
        }
    }
}