global with sharing class UserHandler implements YATF.Handler {
    
    global void handle() {
        if (Trigger.isUpdate){
            updateExistingUsers((List<User>)Trigger.new, (Map<Id, User>)Trigger.oldMap);
        }
    }

    global void updateExistingUsers(List<User> newUsersList, Map<Id, User> oldUsersMap) {
        Boolean userDeactivated = false;
        // Loop through Trigger.new to check if any users were deactivated
        List<User> usersToDeactivate = new List<User>();
        for (User newUser : newUsersList) {
            User oldUser = oldUsersMap.get(newUser.Id);
            // Check if user has been deactivated
            userDeactivated = (oldUser.IsActive == TRUE && newUser.IsActive == FALSE);
            // Check if the user was deactivated (IsActive was TRUE and is now FALSE)
            if (userDeactivated) {
                // Mark the user as deactivated
                userDeactivated = true;
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

        // Reassign accounts asynchronously using the @future method
        AccountReassignmentHandler.reassignAccountsAsync(deactivatedUserIds);
    }
}

