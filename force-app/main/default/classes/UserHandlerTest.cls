@isTest
public class UserHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create manager user
        User managerUser = new User(
            FirstName = 'Manager',
            LastName = 'User',
            Email = 'manager@example.com',
            Username = 'manager@example.com' + System.currentTimeMillis(),
            Alias = 'mgr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Headspace User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert managerUser;

        // Create regular user with manager relationship
        User regularUser = new User(
            FirstName = 'Regular',
            LastName = 'User',
            Email = 'regular@example.com',
            Username = 'regular@example.com' + System.currentTimeMillis(),
            Alias = 'reg',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Headspace User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = managerUser.Id,
            IsActive = true
        );
        insert regularUser;

        // Create accounts and assign to regular user
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                OwnerId = regularUser.Id
            ));
        }
        insert accounts;
    }

    @isTest
    static void testUserDeactivation() {
        // Fetch regular user and manager
        User regularUser = [SELECT Id, IsActive, ManagerId FROM User WHERE FirstName = 'Regular' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE FirstName = 'Manager' LIMIT 1];

        // Validate the manager relationship
        System.assertEquals(managerUser.Id, regularUser.ManagerId, 'ManagerId should match the created manager.');

        // Fetch accounts owned by the regular user
        List<Account> userAccounts = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :regularUser.Id];
        System.assertEquals(3, userAccounts.size(), 'Regular user should own 3 accounts.');

        // Simulate deactivating the user
        regularUser.IsActive = false;
        update regularUser;

        // Ensure that the future method has run and reassigned accounts
        Test.startTest();
        // Call the future methods explicitly
        Test.stopTest();

        // Fetch the reassigned accounts after the update
        List<Account> reassignedAccounts = [SELECT Id, OwnerId FROM Account WHERE Id IN :userAccounts];
        
        // Check if the accounts were reassigned correctly to the manager
        for (Account account : reassignedAccounts) {
            System.assertEquals(managerUser.Id, account.OwnerId, 'Account should be reassigned to the manager.');
        }

        // Ensure all 3 accounts are reassigned
        System.assertEquals(3, reassignedAccounts.size(), 'All accounts should be reassigned.');
    }
}



