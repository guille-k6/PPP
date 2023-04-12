public class UnitResponseService {
    public static void checkResponses(List<UnitResponse__c> unitResponses){
        // Lista de Ids de unidades en las UnitsReponses que vienen por parámetro
        List<Id> unitsId = new List<Id>();
        for(UnitResponse__c u : unitResponses){
            unitsId.add(u.Unit__c);
        }
        
        // Map of units
        Map<Id, Unit__c> unitsMap = new Map<Id, Unit__c>();
        List<Unit__c> units = [SELECT Id, Points__c, Name, Estimated_Time__c, Module__c, Content__c FROM Unit__c WHERE Id in :unitsId];
        for(Unit__c u : units){
            unitsMap.put(u.Id, u);
        }
       
        // Quereamos las preguntas que estan en estas unidades(units) con su respuesta correctas
        List<Question__c> questions = [SELECT Id, (SELECT Id, isCorrect__c FROM Options__r WHERE isCorrect__c = true)
                                       FROM Question__c
                                       WHERE Unit__c in :unitsId];
              
        // Mapa de preguntas con sus respuestas correctas.
        // Map<ID = Question__c, ID = Options__c CORRECTA>;
        Map<Id, Id> questionOptionsMap = new Map<Id, Id>();
        // Loop through questions and their related options to populate the map.
        for (Question__c q : questions) {
            questionOptionsMap.put(q.Id, q.Options__r[0].Id);
        }
        
        // Quereamos todas las questionsResponse que vienen dentro de la lista de las unitResponses
        List<QuestionResponse__c> qr = [SELECT Id, Option__c, UnitResponse__c, Question__c
                                        FROM QuestionResponse__c
                                        WHERE UnitResponse__c in :unitResponses];
        
        // Mapa de Unidades respondidas del usuario con sus respectivas respuestas.
        Map<UnitResponse__c, List<QuestionResponse__c>> UnitWithQuestions = new Map<UnitResponse__c, List<QuestionResponse__c>>();
        for(UnitResponse__c ur : unitResponses){
            List<QuestionResponse__c> listOfResponses = new List<QuestionResponse__c>();
            for(QuestionResponse__c questionResponses : qr){
                if(questionResponses.UnitResponse__c == ur.Id){
                    listOfResponses.add(questionResponses);
                }
            }
            UnitWithQuestions.put(ur, listOfResponses);
        }
        
        // Ahora vemos si las respuetas a la unidad respondida por el usuario son correctas.
        for(UnitResponse__c ur : UnitWithQuestions.keySet()){
            List<QuestionResponse__c> responsesToUnit = UnitWithQuestions.get(ur);
            Boolean isUnitCorrect = true;
            for(QuestionResponse__c response : responsesToUnit){
                if(response.Option__c != questionOptionsMap.get(response.Question__c)){
                    isUnitCorrect = false;
                }
            }
            if(isUnitCorrect){
            	ur.Status__c = 'Success';
                Integer unitPoints = Integer.valueOf(unitsMap.get(ur.Unit__c).Points__c);
                if(ur.Attempts__c == 1){
                    ur.Points_Achieved__c = unitPoints;
                }else if(ur.Attempts__c == 2){
                    ur.Points_Achieved__c = (unitPoints / 2);
                }else if(ur.Attempts__c > 2){
                    ur.Points_Achieved__c = (unitPoints / 4);
                }
            }else{
                ur.Status__c = 'Fail';
            }
        }
        
    }
    
    public static void checkPointsUser(List<UnitResponse__c> unitResponses){
        Set<Id> unitResponsesIds = new Set<Id>();
        for (UnitResponse__c ur : unitResponses){
            unitResponsesIds.add(ur.Id);
        }

        List<UnitResponse__c> urSuccess = [SELECT Id, Points_Achieved__c, User__c, Status__c FROM UnitResponse__c WHERE Status__c = 'Success' AND Id in :unitResponsesIds];
        
        Set<Id> userIds = new Set<Id>();
        for (UnitResponse__c us : urSuccess){
            userIds.add(us.User__c);
        }
        
        List<User> users = [SELECT Id, Name, Score__c FROM User WHERE Id in :userIds];
        
        for (UnitResponse__c urS : urSuccess){
            for (User Us : users) {
                if (urS.User__c == us.Id){
                    if(Us.Score__c == null){
                        Us.Score__c = 0;
                    }
                    Us.Score__c = Us.Score__c + urS.Points_Achieved__c;
                }
            }
        }
        Update users;
    }
}