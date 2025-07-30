public without sharing class ClientHelper {

    public static Map<String, Id> insertClient(String firstName, String lastName, String email, String phone) {
        Map<String, Id> result = new Map<String, Id>();

        if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(email) || String.isBlank(phone)) {
            throw new AuraHandledException('First name, last name, email and phone are required to insert client.');
        }

        List<Contact> existingContacts = [
            SELECT Id 
            FROM Contact 
            WHERE FirstName = :firstName 
              AND LastName = :lastName 
              AND Email = :email
            LIMIT 1
        ];

        if (!existingContacts.isEmpty()) {
            result.put('Contact', existingContacts[0].Id);
        } else {
            Lead newLead = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Company = 'New Client',
                Status = 'Open - Not Contacted'
            );
            insert newLead;
            result.put('Lead', newLead.Id);
        }

        return result;
    }
}
