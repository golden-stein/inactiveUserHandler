// find manager (reporting) and assign to them

public with sharing class UserHandler implements YATF.Handler {
    
    
    public void handle() {
        updateExistingUsers((List<User>) Trigger.new, (Map<Id, User>) Trigger.oldMap);
    }

    public void updateExistingUsers(List<User> newUsersList, Map<Id,User> oldUsersMap) {
        Boolean userDeactivated;
        
        for(User newUser : newUsersList) {
            User oldUser = oldUsersMap.get(newUser.Id);
            
            // Set variable
            userDeactivated = (oldUser.IsActive == TRUE && newUser.IsActive == FALSE);
            
            // Check if user is deactivated
             if (userDeactivated) {
                // Check if user owns any accounts
                List<Account> accountsOwned = [SELECT Id FROM Account WHERE OwnerId = :newUser.Id];
                if (accountsOwned.size() > 0) {
                    // Get manager of deactivated user
                    Id managerId = [SELECT ManagerId FROM User WHERE Id = :newUser.Id].ManagerId;
                    // Loop through accounts owned by user
                    for (Account userOwnedAccount : accountsOwned) {
                        // Assign to manager
                        userOwnedAccount.OwnerId = managerId;
                    }
                }
                // Update accounts
                update accountsOwned;
                // Create new account list view
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();
                MetadataService.ListView listView = new MetadataService.ListView();
                listView.fullName = 'Account.MyListView';
                listView.label = 'My List View';
                listView.filterScope = 'Everything';
                listView.columns = new List<String> { 'NAME' }; 
                service.updateMetadata(new MetadataService.ListView[] { listView });
                // changes here
             }
        }
    }
}