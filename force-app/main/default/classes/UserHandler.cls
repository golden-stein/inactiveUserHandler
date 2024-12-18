public with sharing class UserHandler implements YATF.Handler {
    
    public void handle() {
        if (Trigger.isUpdate) {
            updateExistingUsers((List<User>) Trigger.new, (Map<Id, User>) Trigger.oldMap);
        }
    }

    public void updateExistingUsers(List<User> newUsersList, Map<Id, User> oldUsersMap) {
        Set<Id> deactivatedUserIds = new Set<Id>();
        
        for (User newUser : newUsersList) {
            User oldUser = oldUsersMap.get(newUser.Id);
            
            // Ensure we're checking only for deactivations
            if (oldUser.IsActive == true && newUser.IsActive == false) {
                deactivatedUserIds.add(newUser.Id);
            }
        }

        if (!deactivatedUserIds.isEmpty()) {
            // Query and process as in the refactored logic shared earlier
            List<Account> accountsToUpdate = [
                SELECT Id, OwnerId 
                FROM Account 
                WHERE OwnerId IN :deactivatedUserIds
            ];

            Map<Id, Id> userToManagerMap = new Map<Id, Id>();
            for (User user : [
                SELECT Id, ManagerId 
                FROM User 
                WHERE Id IN :deactivatedUserIds
            ]) {
                userToManagerMap.put(user.Id, user.ManagerId);
            }

            for (Account account : accountsToUpdate) {
                account.OwnerId = userToManagerMap.get(account.OwnerId);
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}
