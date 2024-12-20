global with sharing class UserHandler implements YATF.Handler {

    global void handle() {
        if (Trigger.isUpdate) {
            List<User> deactivatedUsers = getDeactivatedUsers((List<User>) Trigger.new, (Map<Id, User>) Trigger.oldMap);

            for (User deactivatedUser : deactivatedUsers) {
                // Fetch the manager for the user
                User manager = [SELECT Id FROM User WHERE Id = :deactivatedUser.ManagerId LIMIT 1];

                if (manager != null) {
                    // Enqueue the first Queueable job
                    System.enqueueJob(new AccountReassignmentJob(deactivatedUser.Id, manager.Id));
                }
            }
        }
    }

    private List<User> getDeactivatedUsers(List<User> newUsers, Map<Id, User> oldUsersMap) {
        List<User> deactivatedUsers = new List<User>();

        for (User newUser : newUsers) {
            User oldUser = oldUsersMap.get(newUser.Id);
            if (oldUser.IsActive && !newUser.IsActive) {
                deactivatedUsers.add(newUser);
            }
        }
        return deactivatedUsers;
    }
}





