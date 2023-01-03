@IsTest
public class ProspectStudentTriggerHandlerTest {
    
    @isTest
    static void testWhenWeUpdateApprovedCheckStudentCreated(){
        // Given
        Class__c newCls = new Class__c();
        newCls.Class__c ='I';
        newCls.Year__c = '2022';
        
        Insert newCls;
        
        Prospect_Student__c ps = new Prospect_Student__c();
        ps.Name = 'Test';
        ps.DOB__c = Date.newInstance(1960, 2, 17);
        ps.Gender__c = 'Male';
        ps.Joining_Year__c = Date.newInstance(2022, 7, 6);
        ps.Class__c = 'I';
        ps.Status__c = 'New';
        
        Insert ps;
        
        //When
        ps.Status__c = 'Approved';
        update ps;
        
        //Then
        List<Student__c> stuList = [select id from Student__c where Name =:ps.Name and DOB__C =:ps.DOB__c and Gender__c =: ps.Gender__c ];
        system.assertEquals(1, stuList.size());
    }
    
    @isTest
    static void testWhenWeUpdateRejected(){
        // Given
        Prospect_Student__c ps = new Prospect_Student__c();
        ps.Name = 'Test';
        ps.DOB__c = Date.newInstance(1960, 2, 17);
        ps.Gender__c = 'Male';
        ps.Joining_Year__c = Date.newInstance(2022, 7, 6);
        ps.Class__c = 'I';
        ps.Status__c = 'New';
        
        Insert ps;
        
        //When
        ps.Status__c = 'Rejected';
        update ps;
        
        //Then
        List<Student__c> stuList = [select id from Student__c where Name =:ps.Name and DOB__C =:ps.DOB__c and Gender__c =: ps.Gender__c ];
        system.assertEquals(0, stuList.size());
    }
    
    @isTest
    static void testWhenWeUpdateApproved(){
        // Given
        
        Class__c newCls = new Class__c();
        newCls.Class__c ='VI';
        newCls.Year__c = '2022';
        
        Insert newCls;
        
        Prospect_Student__c ps = new Prospect_Student__c();
        ps.Name = 'Test';
        ps.DOB__c = Date.newInstance(1960, 2, 17);
        ps.Gender__c = 'Male';
        ps.Joining_Year__c = Date.newInstance(2022, 7, 6);
        ps.Class__c = 'VI';
        ps.Status__c = 'New';
        
        Insert ps;
        
        //When
        ps.Status__c = 'Approved';
        update ps;
        
        //Then
        Student__c stuList = [select id from Student__c where Name =:ps.Name and DOB__C =:ps.DOB__c and Gender__c =: ps.Gender__c];
        
        List<StudentClass__c> stuCls = [select id from StudentClass__c where Student__c =:stuList.Id AND Class__c =:newCls.id];
        system.assertEquals(1,stuCls.size());
    }
}