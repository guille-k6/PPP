@isTest
public class UnitServiceTest {

    @isTest
    private static void firstTestMethod(){
        
        User testUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        Module__c module = new Module__c(
            Name = 'PrimerModuloTest',
            Roles__c = 'Admin',
            Skills__c = 'Apex'
        );
        insert module;
        
        Unit__c unit = new Unit__c(
        	Module__c = module.id,
            Points__c = 100,
            Content__c = 'First unit content',
            Estimated_Time__c = 20
        );
        insert unit;
        
        Question__c question = new Question__c(
            Unit__c = unit.id,
            Description__c = 'Question description, the real question'
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.id,
            Description__c = 'Option descrition, the real option',
            isCorrect__c = true
        );
        insert option;
        
        QuestionResponse__c questionResponse = new QuestionResponse__c(
            Question__c = question.id,
            Option__c = option.id
        );
        insert questionResponse;

        
        Map<Id, Id> jsonAnswers = new Map<Id, Id>();
        jsonAnswers.put(question.id, option.id);
        
        Object testAnswers = jsonAnswers;
        
        test.startTest();
        Boolean result = UnitService.saveAnswers(unit.Id, testAnswers);
        test.stopTest();
        
        System.assertEquals(true, result);
        List<UnitResponse__c> unitResponses = [SELECT Id, Status__c FROM UnitResponse__c WHERE Unit__c = :unit.Id];
        System.assertEquals(1, unitResponses.size());
        System.assertEquals('Success', unitResponses[0].Status__c);
        
        List<QuestionResponse__c> questionResponses = [SELECT Id, Question__c, Option__c FROM QuestionResponse__c WHERE UnitResponse__c = :unitResponses[0].Id];
        System.assertEquals(1, questionResponses.size());
        System.assertEquals(question.Id, questionResponses[0].Question__c);
        System.assertEquals(option.Id, questionResponses[0].Option__c);
    }
   
    @isTest
    private static void secondTestMethod(){
        
        User testUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        Module__c module = new Module__c(
            Name = 'PrimerModuloTest',
            Roles__c = 'Admin',
            Skills__c = 'Apex'
        );
        insert module;
        
        Unit__c unit = new Unit__c(
        	Module__c = module.id,
            Points__c = 100,
            Content__c = 'First unit content',
            Estimated_Time__c = 20
        );
        insert unit;
        
        Question__c question = new Question__c(
            Unit__c = unit.id,
            Description__c = 'Question description, the real question'
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.id,
            Description__c = 'Option descrition, the real option',
            isCorrect__c = true
        );
        insert option;
        
        ModuleResponse__c moduleResponse = new ModuleResponse__c(
            Module__c = module.id,
            User__c = testUser.id
        );
        insert moduleResponse;
        
        QuestionResponse__c questionResponse = new QuestionResponse__c(
            Question__c = question.id,
            Option__c = option.id
        );
        insert questionResponse;

        
        Map<Id, Id> jsonAnswers = new Map<Id, Id>();
        jsonAnswers.put(question.id, option.id);
        
        Object testAnswers = jsonAnswers;
        
        test.startTest();
        Boolean result = UnitService.saveAnswers(unit.Id, testAnswers);
        test.stopTest();
        
        System.assertEquals(true, result);
        List<UnitResponse__c> unitResponses = [SELECT Id, Status__c FROM UnitResponse__c];
        System.assertEquals(1, unitResponses.size());
        System.assertEquals('Success', unitResponses[0].Status__c);
        
        List<QuestionResponse__c> questionResponses = [SELECT Id, Question__c, Option__c FROM QuestionResponse__c WHERE UnitResponse__c = :unitResponses[0].Id];
        System.assertEquals(1, questionResponses.size());
        System.assertEquals(question.Id, questionResponses[0].Question__c);
        System.assertEquals(option.Id, questionResponses[0].Option__c);
    }

    @isTest
    private static void thirdTestMethod(){
        
        User testUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        Module__c module = new Module__c(
            Name = 'PrimerModuloTest',
            Roles__c = 'Admin',
            Skills__c = 'Apex'
        );
        insert module;
        
        Unit__c unit = new Unit__c(
        	Module__c = module.id,
            Points__c = 100,
            Content__c = 'First unit content',
            Estimated_Time__c = 20
        );
        insert unit;
        
        Question__c question = new Question__c(
            Unit__c = unit.id,
            Description__c = 'Question description, the real question'
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.id,
            Description__c = 'Option descrition, the real option',
            isCorrect__c = true
        );
        insert option;
        
        Option__c wrongOption = new Option__c(
            Question__c = question.id,
            Description__c = 'Option descrition, the real incorrect option',
            isCorrect__c = false
        );
        insert wrongOption;
        
        ModuleResponse__c moduleResponse = new ModuleResponse__c(
            Module__c = module.id,
            User__c = testUser.id
        );
        insert moduleResponse;
        
        QuestionResponse__c questionResponse = new QuestionResponse__c(
            Question__c = question.id,
            Option__c = wrongOption.id
        );
        insert questionResponse;

        
        Map<Id, Id> jsonAnswers = new Map<Id, Id>();
        jsonAnswers.put(question.id, wrongOption.id);
        
        Object testAnswers = jsonAnswers;
        
        test.startTest();
        Boolean result = UnitService.saveAnswers(unit.Id, testAnswers);
        test.stopTest();
        
        System.assertEquals(true, result);
        List<UnitResponse__c> unitResponses = [SELECT Id, Status__c FROM UnitResponse__c];
        System.assertEquals(1, unitResponses.size());
        System.assertEquals('Fail', unitResponses[0].Status__c);
        
        List<QuestionResponse__c> questionResponses = [SELECT Id, Question__c, Option__c FROM QuestionResponse__c WHERE UnitResponse__c = :unitResponses[0].Id];
        System.assertEquals(1, questionResponses.size());
        System.assertEquals(question.Id, questionResponses[0].Question__c);
        System.assertEquals(wrongOption.Id, questionResponses[0].Option__c);
    }
    
    @isTest
    private static void testWrappers(){
        User testUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        Trail__c trail = new Trail__c(
            Name = 'Primer trail',
            Description__c = 'Una desc'
        );
        insert trail;
        
        Trail_Progress__c trailProgress = new Trail_Progress__c(
            User__c = testUser.Id,
            Trail__c = trail.id
        );
        insert trailProgress;
        
        Module__c module = new Module__c(
            Name = 'PrimerModuloTest',
            Roles__c = 'Admin',
            Skills__c = 'Apex',
            Active__c = true
        );
        insert module;
        
        Trail_Module__c trailModule = new Trail_Module__c(
            Trail__c = trail.id,
            Module__c = module.id
        );
        insert trailModule;
        
        Unit__c unit = new Unit__c(
            Module__c = module.id,
            Points__c = 100,
            Content__c = 'First unit content',
            Estimated_Time__c = 20
        );
        insert unit;
        
        Question__c question = new Question__c(
            Unit__c = unit.id,
            Description__c = 'Question description, the real question'
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.id,
            Description__c = 'Option descrition, the real option',
            isCorrect__c = true
        );
        insert option;
        
        ModuleResponse__c moduleResponse = new ModuleResponse__c(
            Module__c = module.id,
            User__c = testUser.id,
            Status__c = 'Complete'
        );
        insert moduleResponse;
        
        UnitResponse__c unitResponse = new UnitResponse__c(
            ModuleResponse__c = moduleResponse.id,
            Unit__c = unit.id,
            Status__c = 'Success'
        );
        insert unitResponse;
        
        Test.startTest();
        UnitService.TrailWrapper tw = UnitService.getTrailWrapper(trail.id);
        UnitService.UnitWrapper uw = UnitService.getUnitWrapper(unit.Id);
        Test.stopTest();
        
        System.assert(tw != null);
        System.assertEquals('Primer trail', tw.trail.Name);
        System.assert(uw != null);
    }
        
}