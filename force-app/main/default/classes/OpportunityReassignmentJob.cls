public class OpportunityReassignmentJob implements Queueable {
    private List<User> deactivatedUsers;

    public OpportunityReassignmentJob(List<User> deactivatedUsers) {
        this.deactivatedUsers = deactivatedUsers;
    }

    public void execute(QueueableContext context) {
        List<Opportunity> oppsToReassign = new List<Opportunity>();

        // Collect all opportunities to reassign
        for (User u : deactivatedUsers) {
            List<Opportunity> opps = [SELECT Id, OwnerId, Owner.ManagerId FROM Opportunity WHERE OwnerId = :u.Id];
            for (Opportunity opp : opps) {
                // Assign to the manager
                opp.OwnerId = opp.Owner.ManagerId;  
                oppsToReassign.add(opp);
            }
        }

        // Update opportunities with the new owner
        if (!oppsToReassign.isEmpty()) {
            update oppsToReassign;
        }
    }
}