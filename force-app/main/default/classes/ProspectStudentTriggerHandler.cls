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
        Set<Id> idSet = fetchRecordsWhichHaveApproved((List<Prospect_Student__c>) Trigger.new);
        if(idSet.size() != 0){
            List<Prospect_Student__c> updateStudents = [Select id,Name,Status__c,DOB__c,Gender__c,Class__c,Joining_Year__c FROM Prospect_Student__c where id IN :idSet];
            // Now we have Approved Students List so we are going to create Student Records Using details...
            List<Student__c> studentsList=  creatingStudents(updateStudents);
            // After that we need to create studentClass as well.. so we need Their class Name...
            List<String> classAndYear= addingClsAndYear(updateStudents);
            Insert studentsList;
            // we have class Name so we need to find the class name Id then Only we can able to create StudentClass record...
            Map<String,Id> classWithId =  findClassIdUsingClassName(classAndYear); 
            Integer i = 0;
            List<StudentClass__c> studentClassList = new List<StudentClass__c>();
            // Once we getting Student Id and Class Id we create a StudentClass Record for respective Student
            for(String key : classAndYear ){
                StudentClass__c stuCls = new StudentClass__c();
                stuCls.Class__c = classWithId.get(key);
                stuCls.Student__c = studentsList.get(i).id;
                studentClassList.add(stuCls);
                i++;
            }
            Insert studentClassList;
        }
    }
    
    private static set<Id> fetchRecordsWhichHaveApproved(List<Prospect_Student__c> prospectList){
        Set<Id> idSet = new Set<Id>();
        for(Prospect_Student__c student : (List<Prospect_Student__c>) Trigger.new){
            Prospect_Student__c oldStudent = (Prospect_Student__c) Trigger.oldMap.get(student.id);
            if(student.Status__c != oldStudent.Status__c && student.Status__C == 'Approved') {
                idSet.add(student.Id);
            }
        }
        return idSet;
    }
    
    private static List<Student__c> creatingStudents(List<Prospect_Student__c> prospectList){
        List<Student__c> studentsList = new List<Student__c>();
        for(Prospect_Student__c candidate :  prospectList){
            Student__c newStu = new Student__c();
            newStu.Name = candidate.Name;
            newStu.DOB__c = candidate.DOB__c;
            newStu.Gender__c = candidate.Gender__c;
            newStu.Joining_Year__c = candidate.Joining_Year__c;
            studentsList.add(newStu);
        }
        return studentsList;
    }
    private static List<String> addingClsAndYear(List<Prospect_Student__c> prospectList){
        List<String> classAndYear = new List<String>();
        for(Prospect_Student__c candidate :  prospectList){
            integer value = candidate.Joining_Year__c.year();
            String year = string.valueOf(value);
            String clsYear = candidate.Class__c +  year;
            classAndYear.add(clsYear);
        }
        return classAndYear;
    }
    private static Map<String,Id> findClassIdUsingClassName(List<String> classNameList){
        Map<String,Id> classWithId = new Map<String,Id>();
        for(Class__c clI :[select id,Name,Class__c,Class_Name__c From Class__c where Class_Name__c IN : classNameList]){
            classWithId.put(clI.Class_Name__c,clI.Id);
        }
        return classWithId;
    }
}