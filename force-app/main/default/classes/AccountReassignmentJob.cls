public class AccountReassignmentJob implements Queueable {
    private List<User> deactivatedUsers;

    public AccountReassignmentJob(List<User> deactivatedUsers) {
        this.deactivatedUsers = deactivatedUsers;
    }

    public void execute(QueueableContext context) {
        List<Account> accountsToReassign = new List<Account>();

        // Collect all accounts to reassign
        for (User u : deactivatedUsers) {
            List<Account> accounts = [SELECT Id, OwnerId, Owner.ManagerId FROM Account WHERE OwnerId = :u.Id];
            for (Account acc : accounts) {
                // Assign to the manager
                acc.OwnerId = acc.Owner.ManagerId;  
                accountsToReassign.add(acc);
            }
        }

        // Update accounts with the new owner
        if (!accountsToReassign.isEmpty()) {
            update accountsToReassign;
        }
    }
}


