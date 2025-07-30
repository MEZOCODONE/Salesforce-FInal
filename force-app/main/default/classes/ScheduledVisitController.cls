    public without sharing class ScheduledVisitController {

        @AuraEnabled(cacheable=true)
        public static List<String> getVisitTimesByNurse(Id nurseId, Date targetDate) {
            return ScheduledVisitHelper.getVisitTimesByNurse(nurseId, targetDate);
        }

        @AuraEnabled
        public static void insertScheduledVisit(ScheduledVisitWrapper wrapper) {
            try {
                ScheduledVisitHelper.insertScheduledVisit(wrapper);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

    }
