public with sharing class UserHandler {

    public static void processDeactivatedUsers(List<User> newUsers, Map<Id, User> oldUsersMap) {
        List<User> deactivatedUsers = new List<User>();

        // Identify users who have been deactivated
        for (User u : newUsers) {
            if (Trigger.isBefore) {
                User oldUser = oldUsersMap.get(u.Id);
                if (u.IsActive == FALSE && oldUser.IsActive == TRUE && oldUser != null) {
                    deactivatedUsers.add(u);
                }
            }
        }
        
        // If there are deactivated users, enqueue the account reassignment job
        if (deactivatedUsers.isEmpty() == FALSE) {
            // Enqueue AccountReassignmentJob
            System.enqueueJob(new AccountReassignmentJob(deactivatedUsers));
            System.debug('Enqueued AccountReassignmentJob');

            // Enqueue OpportunityReassignmentJob
            System.enqueueJob(new OpportunityReassignmentJob(deactivatedUsers));
            System.debug('Enqueued OpportunityReassignmentJob');

            // Enqueue CaseReassignmentJob
            // System.enqueueJob(new CaseReassignmentJob(deactivatedUsers));
            // System.debug('Enqueued CaseReassignmentJob');
        }
    }
}








