@isTest
public class AccountReassignmentJobTest {
    @testSetup
    static void setupTestData() {
        User manager = new User(
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
        insert manager;

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
            ManagerId = manager.Id,
            IsActive = true
        );
        insert regularUser;

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, OwnerId = regularUser.Id));
        }
        insert accounts;
    }

    @isTest
    static void testAccountReassignment() {
        User regularUser = [SELECT Id, ManagerId FROM User WHERE FirstName = 'Regular' LIMIT 1];
        User manager = [SELECT Id FROM User WHERE FirstName = 'Manager' LIMIT 1];

        Test.startTest();
        System.enqueueJob(new AccountReassignmentJob(regularUser.Id, manager.Id));
        Test.stopTest();

        List<Account> reassignedAccounts = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :manager.Id];
        System.assertEquals(3, reassignedAccounts.size(), 'All accounts should be reassigned to the manager.');
    }
}
