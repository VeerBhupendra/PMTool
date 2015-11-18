trigger ShareRecords on User_Story__c (after insert,after update) {
    // Define connection id 
    Id networkId = ConnectionHelper.getConnectionId('Appssential'); 
    
    Set<Id> localContactAccountSet = new Set<Id>(); 
    List<User_Story__c> localContacts = new List<User_Story__c>(); 
    Set<Id> sharedAccountSet = new Set<Id>();    
    
    // only share records created in this org, do not add contacts received from another org. 
    for (User_Story__c newContact : TRIGGER.new) { 
        if (newContact.ConnectionReceivedId == null && newContact.US_Opportunity__c != null) { 
            localContactAccountSet.add(newContact.US_Opportunity__c);
            localContacts.add(newContact); 
        }         
    } 
    
    if (localContactAccountSet.size() > 0) { 
        // Get the contact account's partner network record connections 
        for (PartnerNetworkRecordConnection accountSharingRecord :  
                                  [SELECT p.Status, p.LocalRecordId, p.ConnectionId 
                                   FROM PartnerNetworkRecordConnection p              
                                   WHERE p.LocalRecordId IN :localContactAccountSet]) { 
                  
            // for each partner connection record for contact's account, check if it is active 
            if ((accountSharingRecord.status.equalsignorecase('Sent') 
              || accountSharingRecord.status.equalsignorecase('Received')) 
              && (accountSharingRecord.ConnectionId == networkId)) { 
                sharedAccountSet.add(accountSharingRecord.LocalRecordId); 
            }               
        } 
            
        if (sharedAccountSet.size() > 0) { 
            List<PartnerNetworkRecordConnection> contactConnections =  new  List<PartnerNetworkRecordConnection>(); 
            
            for (User_Story__c newContact : localContacts) { 
  
                if (sharedAccountSet.contains(newContact.US_Opportunity__c)) { 
                   
                    PartnerNetworkRecordConnection newConnection = 
                      new PartnerNetworkRecordConnection( 
                          ConnectionId = networkId, 
                          LocalRecordId = newContact.Id, 
                          SendClosedTasks = false, 
                          SendOpenTasks = false, 
                          SendEmails = false, 
                          ParentRecordId = newContact.US_Opportunity__c); 
                          
                    contactConnections.add(newConnection); 
                
                } 
            } 
  
            if (contactConnections.size() > 0 ) { 
                   database.insert(contactConnections);
                	System.debug('VVVVVVVVVVVVVVVVVVVeeeeerrr'+contactConnections);
            } 
        } 
    } 
}