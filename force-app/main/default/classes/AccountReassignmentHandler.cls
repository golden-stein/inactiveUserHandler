global with sharing class AccountReassignmentHandler {

    @InvocableMethod
    public static void handleAccountReassignments(List<AccountReassignmentEvent__e> events) {
        Set<Id> deactivatedUserIds = new Set<Id>();

        // Extract deactivated user IDs from the platform event
        for (AccountReassignmentEvent__e event : events) {
            deactivatedUserIds.add(event.deactivatedUserIds__c);
        }

        // Find all accounts where the owner is one of the deactivated users
        List<Account> accountsToReassign = [SELECT Id, OwnerId FROM Account WHERE OwnerId IN :deactivatedUserIds];

        // Get the ManagerId of the account owners and reassign the accounts to the ManagerId of the current owner
        List<User> users = [SELECT Id, ManagerId FROM User WHERE Id IN :deactivatedUserIds];

        // Create a map to hold ManagerId for each user
        Map<Id, Id> userToManagerMap = new Map<Id, Id>();

        for (User u : users) {
            userToManagerMap.put(u.Id, u.ManagerId);
        }

        // Reassign the accounts
        for (Account acc : accountsToReassign) {
            // Get the ManagerId of the current account owner
            Id managerId = userToManagerMap.get(acc.OwnerId);
            if (managerId != null) {
                acc.OwnerId = managerId;  // Reassign owner to the manager of the current account owner
            }
        }

        // Perform the update asynchronously
        update accountsToReassign;
    }
}




