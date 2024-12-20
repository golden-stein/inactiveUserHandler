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
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
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
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ManagerId = managerUser.Id,
            IsActive = true
        );
        insert regularUser;
    }

    @isTest
    static void testHandlerEnqueuesJob() {
        // Fetch the regular user
        User regularUser = [SELECT Id FROM User WHERE FirstName = 'Regular' LIMIT 1];

        // Deactivate the user
        regularUser.IsActive = false;
        Test.startTest();
        update regularUser;
        Test.stopTest();

        // Check the Queueable job
        System.assertEquals(1, Limits.getQueueableJobs(), 'One Queueable job should have been enqueued.');
    }
}






