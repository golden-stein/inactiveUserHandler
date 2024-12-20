public class AccountReassignmentJob implements Queueable {
    private Set<Id> deactivatedUserIds;

    public AccountReassignmentJob(Id userId, Id managerId) {
        this.deactivatedUserIds = new Set<Id>{userId};
    }

    public void execute(QueueableContext context) {
        System.debug('Starting AccountReassignmentJob with users: ' + deactivatedUserIds);

        // Fetch accounts to reassign
        List<Account> accountsToReassign = [
            SELECT Id, OwnerId, Owner.ManagerId 
            FROM Account 
            WHERE OwnerId IN :deactivatedUserIds
        ];

        System.debug('Accounts to reassign: ' + accountsToReassign);

        Map<Id, Id> ownerToManagerMap = new Map<Id, Id>();
        for (Account acc : accountsToReassign) {
            if (acc.Owner.ManagerId != null) {
                ownerToManagerMap.put(acc.OwnerId, acc.Owner.ManagerId);
            }
        }

        // Reassign accounts
        List<Account> updatedAccounts = new List<Account>();
        for (Account acc : accountsToReassign) {
            if (ownerToManagerMap.containsKey(acc.OwnerId)) {
                acc.OwnerId = ownerToManagerMap.get(acc.OwnerId);
                updatedAccounts.add(acc);
            }
        }

        if (!updatedAccounts.isEmpty()) {
            System.debug('Updating accounts: ' + updatedAccounts);
            update updatedAccounts;
        }
    }
}
