# inactiveUserHandler  

**inactiveUserHandler** is a Salesforce Apex package designed to streamline key record ownership transitions when a user is deactivated. By leveraging a before update trigger, the package identifies deactivated users and assigns ownership of their accounts, *opportunities*, and *cases* to their respective managers.  

## Features  
force-app/main/default/triggers/UserTrigger.trigger
- **[Trigger-based automation](force-app/main/default/triggers/UserTrigger.trigger)**: Executes during the `before update` event on user records.  
- **[Account reassignment](force-app/main/default/classes/AccountReassignmentJob.cls)**: Automatically reassigns account ownership to the manager of the deactivated user.
- **[Opportunity reassignment](force-app/main/default/classes/OpportunityReassignmentJob.cls)**: Automatically reassigns opportunity ownership to the manager of the deactivated user. 
- ***Scalable design**: Built using the Yet Another Trigger Framework (YATF) to ensure maintainability and scalability.*

## In Development 
- **Case reassignment**: Automatically reassigns case ownership to the manager of the deactivated user.
- **YATF Handling**: Add handling to match the existing Yet Another Trigger Framework (YATF) to ensure maintainability and scalability.

## Installation  
1. Clone this repository to your local machine:  
   ```bash  
   git clone https://github.com/golden-stein/inactiveUserHandler.git  
   ```  

2. Deploy the Apex code to your Salesforce org using your preferred deployment tool:  
   ```bash
   sfdx force:source:deploy -p ./inactiveUserHandler
   ```  

## Usage  
1. Ensure the trigger and handler class are deployed to your Salesforce org.  
2. Activate the trigger for user updates.  
3. When a user record is updated to inactive (`IsActive = false`), the trigger will execute the following steps:  
   - Identify accounts, opportunities, and cases owned by the deactivated user.  
   - Reassign ownership of those records to the user's manager. 

## File Structure  
- **`UserTrigger`**: The Apex trigger monitoring `before update` events on user records.  
- **`UserHandler`**: The handler class containing the core logic for account reassignment.
- **`AccountReassignmentJob`**: The handler class containing the core logic for account reassignment.
- **`OpportunityReassignmentJob`**: The handler class containing the core logic for opportunity reassignment.
- ***`CaseReassignmentJob`**: The handler class containing the core logic for case reassignment.* 
- **Test Classes**: Comprehensive unit tests ensuring robust functionality and code coverage.  

## Development  
This package ***will eventually*** adhere(s) to the [Yet Another Trigger Framework (YATF)](https://github.com/callawaycloud/yet-another-trigger-framework) to maintain a clean and organized structure for trigger logic.  

## Contributions  
Contributions, issues, and feature requests are welcome! Feel free to submit a pull request or open an issue.  

## License  
This project is licensed under the MIT License. See [LICENSE](https://en.wikipedia.org/wiki/MIT_License) for details.  

## Contact  
For questions or feedback, please open an issue or contact [golden-stein](https://github.com/golden-stein).  
