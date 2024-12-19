trigger UserTrigger on User (after update) {
    // Create YATF Manager to manage the handlers
    YATF.Manager handler = new YATF.Manager();
    handler.manage();
}

