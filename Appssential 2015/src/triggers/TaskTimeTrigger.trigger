trigger TaskTimeTrigger on Task (After Update, After Insert, After Delete,After Undelete) {
    Set<String> userstoryids= new Set<String>();
    if(trigger.isdelete){
      for(Task t :trigger.old){
        if(t.Estimated_Time_To_Code_In_Minutes__c!=null){
            userstoryids.add(t.Whatid);
        }    
      }
    }
    else{
      for(Task t :trigger.new){
            if(t.Estimated_Time_To_Code_In_Minutes__c!=null){
                userstoryids.add(t.Whatid);
            }
      }      
    }
    
    List<User_Story__c> userstoryList = new List<User_Story__c>();
    for(User_Story__c us : [select id,name,US_Total_Estimated_Time_To_Code__c,Total_Actual_Time_To_Code__c,Total_Actual_Time_To_Test__c,Total_Estimated_Time_To_Test__c,(select id,Actual_Time_To_Code_In_Minutes__c,Actual_Time_To_Test__c,
                                        Estimated_Time_To_Code_In_Minutes__c,Estimated_Time_To_Test__c,Actual_Time_To_Admin__c, Estimated_Time_To_Admin__c
                                         From Tasks where 
                                        Estimated_Time_To_Code_In_Minutes__c !=null  ) From User_Story__c where id in : userstoryids]){
        Integer estimatedcodeTime =0;
        Integer actualcodeTime =0;
        Integer actualtestTime =0;
        Integer estimatedtestTime =0;
        Integer estimatedcodeTimeAd =0;
        Integer actualcodeTimeAd =0;

        for(Task t : us.Tasks){
            estimatedcodeTime += Integer.valueOf(t.Estimated_Time_To_Code_In_Minutes__c);
            
            if(t.Actual_Time_To_Code_In_Minutes__c!=null)
                actualcodeTime += Integer.valueOf(t.Actual_Time_To_Code_In_Minutes__c);
            
            if(t.Actual_Time_To_Test__c!=null)
                actualtestTime += Integer.valueOf(t.Actual_Time_To_Test__c);
            
            if(t.Estimated_Time_To_Test__c!=null)
                estimatedtestTime += Integer.valueOf(t.Estimated_Time_To_Test__c);
            
            if(t.Actual_Time_To_Admin__c != null)
                actualcodeTimeAd +=  Integer.valueOf(t.Actual_Time_To_Admin__c);   
            
            if(t.Estimated_Time_To_Admin__c != null)
                estimatedcodeTimeAd +=  Integer.valueOf(t.Estimated_Time_To_Admin__c);
            
        }
        us.US_Total_Estimated_Time_To_Code__c=estimatedcodeTime; 
        us.Total_Actual_Time_To_Code__c=actualcodeTime;                                    
        us.Total_Actual_Time_To_Test__c=actualtestTime;                                    
        us.Total_Estimated_Time_To_Test__c=estimatedtestTime;                                    
        us.Estimated_Time_To_Admin__c = estimatedcodeTimeAd ;
        us.Actual_Time_To_Admin__c = actualcodeTimeAd;
                                           
        userstoryList.add(us);
    }
    update userstoryList;
}