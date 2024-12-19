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

        // If any users were deactivated, publish the platform event
        if (usersToDeactivate.size() > 0) {
            handleAccountReassignments(usersToDeactivate);
        }
    }

    // Publish the Platform Event for account reassignment
    private void handleAccountReassignments(List<User> deactivatedUsers) {
        List<AccountReassignmentEvent__e> events = new List<AccountReassignmentEvent__e>();

        // Prepare the event payload
        for (User u : deactivatedUsers) {
            events.add(new AccountReassignmentEvent__e(
                deactivatedUserIds__c = u.Id
            ));
        }

        // Publish the platform event
        if (!events.isEmpty()) {
            Database.SaveResult[] results = EventBus.publish(events);
        }
    }
}




