@isTest
public class UserHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create a manager user (setup object)
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

        // Create a regular user (setup object)
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

        // Create an account owned by the regular user
        Account acc = new Account(Name = 'Test Account', OwnerId = regularUser.Id);
        insert acc;
    }

    // Test for Queueable Job
    @isTest
    static void testHandlerEnqueuesJob() {
        User regularUser = [SELECT Id, IsActive FROM User WHERE FirstName = 'Regular' LIMIT 1];

        // Deactivate the user and simulate the trigger
        regularUser.IsActive = false;

        // Use Test.startTest() and Test.stopTest() to isolate the job
        Test.startTest();

        // Update the regular user to trigger the deactivation logic (this will call UserHandler)
        update regularUser;

        // Check if the job is enqueued after the update
        Test.stopTest();

        // Assert that the queueable job was enqueued
        System.debug('Number of Queueable Jobs Enqueued: ' + Limits.getQueueableJobs());
        
        System.assertEquals(1, Limits.getQueueableJobs(), 'One Queueable job should have been enqueued.');
    }

    // Test for Account Reassignment
    @isTest
    static void testAccountReassignment() {
        // Ensure the setup data is correct before starting the test
        User manager = [SELECT Id FROM User WHERE FirstName = 'Manager' LIMIT 1];
        User regularUser = [SELECT Id, IsActive FROM User WHERE FirstName = 'Regular' LIMIT 1];

        // Get the account that is owned by the regular user
        Account acc = [SELECT Id, OwnerId FROM Account WHERE OwnerId = :regularUser.Id LIMIT 1];

        // Deactivate the regular user
        regularUser.IsActive = false;

        // Ensure the user update will trigger the reassign process
        Test.startTest();

        // Update the user to trigger the handler logic
        update regularUser;

        // Stop the test to make sure the queueable job is processed
        Test.stopTest();

        // Re-fetch the account to check the owner
        acc = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];

        // Assert that the account's owner was reassigned to the manager
        System.assertEquals(manager.Id, acc.OwnerId, 'The account should be reassigned to the manager.');
    }
}







