trigger UserTrigger on User(after delete) {
    // Invoke YATF handler
    YATF.Manager handler = new YATF.Manager();
    handler.manage();
}