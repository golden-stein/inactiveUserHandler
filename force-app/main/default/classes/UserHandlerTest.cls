@isTest
public class UserHandlerTest {
    @isTest
    public static void testUpdateExistingUsers() {
        // Create test data
        User newUser = new User(
            FirstName = 'New',
            LastName = 'User',
            Email = '{EMAIL_PLACEHOLDER}',
            Username = '{EMAIL_PLACEHOLDER}',
            Alias = 'newuser',
            CommunityNickname = 'newuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert newUser;
        
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = newUser.Id
        );
        insert testAccount;
        
        // Call test method
        Test.startTest();
        newUser.IsActive = FALSE;
        update newUser;
        Test.stopTest();

        // Construct reportName
        String reportName = 'Deactivated User - ' + newUser.FirstName + ' ' + newUser.LastName;
        
        // Verify that the report was saved and emails were sent
        List<Report> reportList = [SELECT Id,Name FROM Report where Name = :reportName];
        System.assertEquals(1, reportList.size());
        
        List<EmailMessage> sentEmails = [SELECT Id, ToAddress, Subject FROM EmailMessage];
        System.assertEquals(1, sentEmails.size());
        System.assertEquals('Deactivated User - New User has been deactivated', sentEmails[0].Subject);
    }
}