public class ProspectStudentTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        for(Prospect_Student__c student : (List<Prospect_Student__c>) Trigger.new) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval. Please approve.');
            req.setObjectId(student.Id);
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(req);
            // display if the reqeust was successful
            System.debug('Submitted for approval successfully: '+result.isSuccess());
        }
    }
    
    public override void afterUpdate(){
        Set<Id> idSet = new Set<Id>();
        Map<String,Id> classWithId = new Map<String,Id>();
        List<StudentClass__c> studentClassList = new List<StudentClass__c>();
        List<Student__c> studentsList = new List<Student__c>();
        Map<String,Date> classandYear = new map<String,Date>(); 
        List<String> clsYear = new List<String>();
        
        // Find Which record Status was updated to new value and we add those record's id to set
        for(Prospect_Student__c student : (List<Prospect_Student__c>) Trigger.new){
            Prospect_Student__c oldStudent = (Prospect_Student__c) Trigger.oldMap.get(student.id);
            if(student.Status__c != oldStudent.Status__c && candidate.Status__C == 'Approved') {
                idSet.add(student.Id);
            }
        }
        if(idSet.size() != 0){
        // Query the record's details using record Id
        List<Prospect_Student__c> updateStudents = [Select id,Name,Status__c,DOB__c,Gender__c,Class__c,Joining_Year__c FROM Prospect_Student__c where id IN :idSet];
        //Loop over the query results and if status was update to Approved we create a new student for the name otherwise we not do anything
        for(Prospect_Student__c candidate : updateStudents){
                Student__c newStu = new Student__c();
                newStu.Name = candidate.Name;
                newStu.DOB__c = candidate.DOB__c;
                newStu.Gender__c = candidate.Gender__c;
                newStu.Joining_Year__c = candidate.Joining_Year__c;
                studentsList.add(newStu);
                // next we need to create a class student for this student so we getting join year and his class
                classandYear.put(candidate.Class__c,candidate.Joining_Year__c);
            
        }
        // Inserting student record then only we can able to create student class record
        Insert studentsList;
        //We just adding class name and year Into string Then only using this we can get the class Id
         for(String key : classandYear.keyset()){
                integer value = classandYear.get(key).year();
                String year = string.valueOf(value);
                clsYear.add(key + year);
            }
        
        // using the actualClassName we can get the cls Id using query
        for(Class__c clI : [select id,Name,Class__c From Class__c where Class_Name__c IN : clsYear]){
                classWithId.put(clI.Class__c,clI.Id);
            
        }
        List<string>  classKeys = new List<String>(classandYear.keyset());
        Integer i = 0;
        // new we have a class Id and student Id so we can able to create student Class
         for(String key : classKeys ){
                StudentClass__c stuCls = new StudentClass__c();
                stuCls.Class__c = classWithId.get(key);
                stuCls.Student__c = studentsList.get(i).id;
                studentClassList.add(stuCls);
                i++;
        }
        Insert studentClassList;
    }
    }
    
}