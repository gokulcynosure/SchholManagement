trigger ProspectStudentTrigger on Prospect_Student__c (after insert,after update) {
    new ProspectStudentTriggerHandler().run();
	}