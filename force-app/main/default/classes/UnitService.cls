public class UnitService{
    
    public class UnitWrapper{
        @AuraEnabled
        public Unit__c unit; 
        @AuraEnabled
        public List<Question__c> questions;  //Listado de Preguntas con Opciones relacionadas
	}
    
    public class TrailWrapper{
        @AuraEnabled
        public Trail__c trail; 
        @AuraEnabled
        public Integer progressTrail; //Porcentaje de progreso del Alumno en el Trail
        @AuraEnabled
        public List<Module__c> modules; //Módulos con Unidades relacionadas
        @AuraEnabled
        public List<Id> passedModuleIds; //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedUnitIds; //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean saveAnswers(Id unitId, Object jsonAnswers){
        // JSON.Serialize jsonAnswers before deserializing in order to make sure it's on proper format.
        // MAP(ID = QUESTION, ID = OPTION)
        Map<Id, Id> answerMap = (Map<Id, Id>) JSON.deserializeStrict(JSON.serialize(jsonAnswers), Map<Id, Id>.class);
        
        //Actual user
        User actualUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        
        // First, we check if there was a previous unitResponse to this unit
        Integer Attempts = 1;
        List<UnitResponse__c> prevUnitResponse = [SELECT Id, Unit__c, User__c, Status__c, Points_Achieved__c, Attempts__c 
                                                  FROM UnitResponse__c 
                                                  WHERE User__c = :actualUser.Id AND Unit__c = :unitId AND Status__c = 'Fail'];
        if (prevUnitResponse.size() > 0){
            Attempts = prevUnitResponse.size() + 1;
        }
        
        // Creation of a response to the unit.
        UnitResponse__c unidadConRespuestas = new UnitResponse__c(Unit__c = unitId, Status__c = 'Draft', User__c = actualUser.Id, Attempts__c = Attempts);
        
        // Query the related module of the unit which comes by parameter.
        List<Unit__c> moduloConfig = [SELECT Id, Module__c FROM Unit__c WHERE Id = :unitId];
        
      	// Query to check if there is a ModuleResponse of the actual user and of the same module.
        List<ModuleResponse__c> userModulo = [SELECT Id FROM ModuleResponse__c WHERE Module__c = :moduloConfig[0].Module__c AND User__c = :actualUser.id];
        
		// If userModule does not exists, a ModuleResponse for that module should be created first.     
        if(userModulo.size() == 0){  
            ModuleResponse__c nuevoUserM = new ModuleResponse__c(Module__c = moduloConfig[0].Module__c, User__c = actualUser.Id, Status__c = 'In progress');
            insert nuevoUserM;    
            unidadConRespuestas.ModuleResponse__c = nuevoUserM.Id;
        }
        // If userModule does exists, I append the unit for that module 
        else{
            unidadConRespuestas.ModuleResponse__c = userModulo[0].Id;
        }
        upsert unidadConRespuestas; 
        
        
        // Creation of answers record for each answered question.
        List<QuestionResponse__c> unitResponses = new List<QuestionResponse__c>();
        
        for (Id questionId : answerMap.keySet()) {
            QuestionResponse__c unitResponse = new QuestionResponse__c(
                UnitResponse__c = unidadConRespuestas.Id,
                Question__c = questionId,
                Option__c = (Id)answerMap.get(questionId)
            );
            unitResponses.add(unitResponse);
        }
        insert unitResponses;
        
        // My UnitResponse object is now in "Answered" status
        unidadConRespuestas.Status__c = 'Answered';
        try{
            update unidadConRespuestas;
            if(unidadConRespuestas.Status__c == 'Success'){
                return true;
            }else{
                return false;
            }
        }catch(DmlException e){
            System.debug(e.getMessage());
            return false;
        }  
    }
    
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId){ // MÉTODO GET TRAIL WRAPPER
        // Actual User.
    	User actualUser = [select Id from User where Id = :UserInfo.getUserId()];
        
        // Creation of the wrapper that we will return.
        TrailWrapper wrapper = new TrailWrapper(); 
        
        List<Trail__c> theTrail = [SELECT Id, Name, Description__c, Estimated_Time__c, Points__c FROM Trail__c WHERE Id = :trailId];
        wrapper.trail = theTrail[0];
        
        List<Trail_Progress__c> trailProgress = [SELECT Id, Progress__c FROM Trail_Progress__c WHERE Trail__c = :trailId AND User__c = :actualUser.Id];
        if(trailProgress.size() == 0){
            wrapper.progressTrail = 0;
        }else{
        	wrapper.progressTrail = trailProgress[0].Progress__c.intValue();            
        }

        
        List<Trail_Module__c> trailModules = [SELECT Id, Trail__c, Module__c
                                              FROM Trail_Module__c
                                              WHERE Trail__c = :trailId];
        List<Id> listOfModuleIds = new List<Id>();
        for(Trail_Module__c tm : trailModules){
            listOfModuleIds.add(tm.Module__c);
        }
        // Modules related to the trail.
        List<Module__c> modules = [SELECT Id, Name, Estimated_Time__c, Description__c, Active__c, Roles__c, Skills__c, Points__c, Number_Of_Units__c,
                                   (SELECT Id, Name, Points__c, Estimated_Time__c FROM Units__r)
                                   FROM Module__c WHERE Id in :listOfModuleIds];
        wrapper.modules = modules;
        
        List<ModuleResponse__c> moduleResponses = [SELECT Id, (SELECT Id, Status__c, Unit__c FROM UnitResponses__r) 
                                                   FROM ModuleResponse__c 
                                                   WHERE Module__c in :modules AND User__c = :actualUser.id AND Status__c = 'Complete'];
        Set<Id> moduleResponseIds = new Set<Id>();
        for(ModuleResponse__c mr : moduleResponses){
            moduleResponseIds.add(mr.Id);
        }

        wrapper.passedModuleIds = new List<Id>(moduleResponseIds);
        
		// Units present in the modules of the trail.       
        List<Unit__c> units = [SELECT Id, Module__c, Name, Points__c, Estimated_Time__c, Content__c
                               FROM Unit__c
                               WHERE Module__c in :listOfModuleIds];
        
        // Set of ids of units
        Set<Id> unitsIds = new Set<Id>();
        for(Unit__c u : units){
            unitsIds.add(u.Id);
        }
        // UnitResponses list of this units.
        List<UnitResponse__c> UnitResponsesCorrect = [SELECT Id, Unit__c, Status__c FROM UnitResponse__c
                                                      WHERE Status__c = 'Success' AND Unit__c in :unitsIds];
        Set<Id> unitResponsesId = new Set<Id>();
        for(UnitResponse__c ur : UnitResponsesCorrect){
            unitResponsesId.add(ur.Unit__c);
        }
        
        // Unidades que el usuario respondio correctamente en el trail
        List<Unit__c> unitsCorrects = [SELECT Id FROM Unit__c WHERE Id in :unitResponsesId];
        List<Id> idCorrectUnits = new List<Id>();
        for(Unit__c u : unitsCorrects){
            idCorrectUnits.add(u.Id);
        }
        wrapper.passedUnitIds = idCorrectUnits;
        
        /*Set<Id> unitResponseIds = new Set<Id>();
        for(ModuleResponse__c mr : moduleResponses){
            for(UnitResponse__c ur : mr.UnitResponses__r){
                unitResponseIds.add(ur.Id);
            }
        }
        wrapper.passedUnitIds = new List<Id>(unitResponseIds);*/

        return wrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static UnitWrapper getUnitWrapper(Id unitId){
        // Creates a UnitWrapper object to return.
        UnitWrapper wrapper = new UnitWrapper();
        
        // Get the unit and assign it to the variable.
        Unit__c unit = [SELECT Id, Name, Points__c, Estimated_Time__c, Content__c, Module__c FROM Unit__c WHERE Id = :unitId];
        wrapper.unit = unit;
        
        List<Question__c> questions = [SELECT Id, Name, Description__c, Unit__c, (SELECT Id, Question__c, Description__c, isCorrect__c FROM Options__r)
                     				   FROM Question__c 
                                       WHERE Unit__c = :unitId];
        wrapper.questions = questions;                               
        
        return wrapper;
    }
}