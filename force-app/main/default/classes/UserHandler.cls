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
            System.enqueueJob(new AccountReassignmentJob(deactivatedUsers));
        }
    }
}








