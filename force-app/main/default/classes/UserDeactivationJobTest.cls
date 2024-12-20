@isTest
public class UserDeactivationJobTest {
    @testSetup
    static void setupTestData() {
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
            IsActive = true
        );
        insert regularUser;
    }

    @isTest
    static void testUserDeactivation() {
        User regularUser = [SELECT Id, IsActive FROM User WHERE FirstName = 'Regular' LIMIT 1];

        Test.startTest();
        System.enqueueJob(new UserDeactivationJob(regularUser.Id));
        Test.stopTest();

        User deactivatedUser = [SELECT Id, IsActive FROM User WHERE Id = :regularUser.Id];
        System.assertEquals(false, deactivatedUser.IsActive, 'User should be deactivated.');
    }
}
