public without sharing class OpportunityHelper {

    @AuraEnabled
    public static Opportunity insertOpportunity(String name, Id product2Id, Id centreId, Date appointmentDate) {
        if (String.isBlank(name) || product2Id == null || centreId == null || appointmentDate == null) {
            throw new AuraHandledException('Name, product, centre and appointment date are required to insert opportunity.');
        }
        try {

            Action_Centre__c centre = [SELECT Pricebook__c FROM Action_Centre__c WHERE Id = :centreId LIMIT 1];
            Id pricebook2Id = centre.Pricebook__c;

            Opportunity newOpp = new Opportunity(Name = name, StageName = 'Prospecting', CloseDate = appointmentDate, Pricebook2Id = pricebook2Id);
            insert newOpp;

            PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebook2Id AND Product2Id = :product2Id 
            AND IsActive = true LIMIT 1];

            OpportunityLineItem oli = new OpportunityLineItem( OpportunityId = newOpp.Id, Quantity = 1, PricebookEntryId = pbe.Id, 
            TotalPrice = pbe.UnitPrice);
            insert oli;

            return newOpp;

        } catch (Exception e) {
            throw new AuraHandledException('Error occured while creating an Opportunity: ' + e.getMessage());
        }
    }
}
