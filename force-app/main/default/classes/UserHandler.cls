global with sharing class UserHandler implements YATF.Handler {

    global void handle() {
        if (Trigger.isUpdate){
            updateExistingUsers((List<User>)Trigger.new, (Map<Id, User>)Trigger.oldMap);
        }
    }

    global void updateExistingUsers(List<User> newUsersList, Map<Id, User> oldUsersMap) {
        Boolean userDeactivated = false;
        List<User> usersToDeactivate = new List<User>();

        // Loop through Trigger.new to check if any users were deactivated
        for (User newUser : newUsersList) {
            User oldUser = oldUsersMap.get(newUser.Id);
            // Check if the user was deactivated (IsActive was TRUE and is now FALSE)
            if (oldUser.IsActive == TRUE && newUser.IsActive == FALSE) {
                usersToDeactivate.add(newUser);
            }
        }

        // If any users were deactivated, trigger the account reassignment logic
        if(usersToDeactivate.size() > 0) {
            handleAccountReassignments(usersToDeactivate);
        }
    }

    // Helper method to handle account reassignment after user deactivation
    private void handleAccountReassignments(List<User> deactivatedUsers) {
        Set<Id> deactivatedUserIds = new Set<Id>();

        for (User u : deactivatedUsers) {
            deactivatedUserIds.add(u.Id);
        }

        // Enqueue the account reassignment logic to run in a separate transaction
        System.enqueueJob(new AccountReassignmentHandler(deactivatedUserIds));
    }
}



