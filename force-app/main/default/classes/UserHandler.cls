// find manager (reporting) and assign to them

global class UserHandler implements YATF.Handler {
    
    
    global void handle() {
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
                    // Get report id for accounts report
                    List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'Deactivated_User_Accounts_to_Reassign_PJB'];
                    String reportId = (String)reportList.get(0).get('Id');
                    // Get the report metadata
                    Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
                    Reports.ReportMetadata reportMd = describe.getReportMetadata();
                    // Override filter and run report
                    Reports.ReportFilter filter = reportMd.getReportFilters()[0];
                    filter.setValue(String.valueOf(newUser.Id));
                    Reports.ReportResults reportResult = Reports.ReportManager.runReport(reportId, reportMd, true);
                    // Save as new report and append developer name with deactivated user name
                    Reports.Report rpr = new Reports.Report();
                    String reportName = 'Deactivated User - ' + newUser.FirstName + ' ' + newUser.LastName;
                    rpr.setName(reportName);
                    rpr.setDeveloperName(reportName);
                    // Save report
                    Reports.ReportManager.saveReport(rpr);
                    // Get new report url
                    String url = String.valueOf(reportResult.getReportUrl());
                    // Send email to user
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {'alex.goldstein@headspace.com'};
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Deactivated User - ' + newUser.FirstName + ' ' + newUser.LastName + ' ' + 'has been deactivated');
                    mail.setPlainTextBody('Accounts to Reassign: ' + url);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
             }
        }
    }
}