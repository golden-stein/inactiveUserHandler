public class UserDeactivationJob implements Queueable, Database.AllowsCallouts {
    private Id userId;

    public UserDeactivationJob(Id userId) {
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        User userToDeactivate = [SELECT Id, IsActive FROM User WHERE Id = :userId LIMIT 1];
        userToDeactivate.IsActive = false;
        update userToDeactivate;
    }
}
