@isTest
public class UserHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create a manager user
        User managerUser = new User(
            FirstName = 'Manager',
            LastName = 'User',
            Email = 'manager@example.com',
            Username = 'manager@example.com' + System.currentTimeMillis(),
            Alias = 'mgr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert managerUser;

        // Create a user with the manager relationship
        User regularUser = new User(
            FirstName = 'Regular',
            LastName = 'User',
            Email = 'regular@example.com',
            Username = 'regular@example.com' + System.currentTimeMillis(),
            Alias = 'reg',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = managerUser.Id,
            IsActive = true
        );
        insert regularUser;

        // Create some accounts owned by the regular user
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
    static void testUserDeactivationReassignAccounts() {
        // Fetch the regular user and their accounts
        User regularUser = [SELECT Id, IsActive FROM User WHERE FirstName = 'Regular' LIMIT 1];
        List<Account> userAccounts = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :regularUser.Id];
        System.assertEquals(3, userAccounts.size(), 'Regular user should own 3 accounts.');

        // Simulate deactivating the user
        User updatedUser = regularUser.clone(false, true, true);
        updatedUser.IsActive = false;

        Test.startTest();
        update updatedUser; // Trigger logic will run
        Test.stopTest();

        // Verify accounts are reassigned to the manager
        User managerUser = [SELECT Id FROM User WHERE FirstName = 'Manager' LIMIT 1];
        List<Account> reassignedAccounts = [SELECT Id, OwnerId FROM Account WHERE Id IN :userAccounts];
        for (Account account : reassignedAccounts) {
            System.assertEquals(managerUser.Id, account.OwnerId, 'Account should be reassigned to the manager.');
        }
    }

    @isTest
    static void testNoAccountsOwned() {
        // Create a user who owns no accounts
        User newUser = new User(
            FirstName = 'NoAccount',
            LastName = 'User',
            Email = 'noaccount@example.com',
            Username = 'noaccount@example.com' + System.currentTimeMillis(),
            Alias = 'noacc',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = [SELECT Id FROM User WHERE FirstName = 'Manager' LIMIT 1].Id,
            IsActive = true
        );
        insert newUser;

        // Simulate deactivating the user
        newUser.IsActive = false;

        Test.startTest();
        update newUser; // Trigger logic will run
        Test.stopTest();

        // Verify no accounts are reassigned
        List<Account> accounts = [SELECT Id FROM Account WHERE OwnerId = :newUser.Id];
        System.assertEquals(0, accounts.size(), 'No accounts should exist for this user.');
    }

    @isTest
    static void testNoDeactivation() {
        // Fetch the regular user and simulate an update without deactivating
        User regularUser = [SELECT Id, IsActive FROM User WHERE FirstName = 'Regular' LIMIT 1];
        regularUser.FirstName = 'UpdatedName'; // Change unrelated field

        Test.startTest();
        update regularUser; // Trigger logic will run
        Test.stopTest();

        // Verify accounts still belong to the regular user
        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :regularUser.Id];
        System.assertEquals(3, accounts.size(), 'Accounts should remain with the regular user.');
    }
}

