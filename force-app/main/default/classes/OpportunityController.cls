public with sharing class OpportunityController {

    @AuraEnabled
    public static Opportunity insertOpportunity(String name, Id product2Id, Id centreId, Date appointmentDate) {
        try{
            return OpportunityHelper.insertOpportunity(name, product2Id, centreId, appointmentDate);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}