trigger UserTrigger on User (before update) {
    // Call the handler to process deactivated users
    UserHandler.processDeactivatedUsers(Trigger.new, Trigger.oldMap);
}


