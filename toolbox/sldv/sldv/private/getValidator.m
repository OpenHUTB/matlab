function validator=getValidator(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap)



    if nargin<5
        goalIdToObjectiveIdMap=[];
    end


    validator=[];
    switch sldvData.AnalysisInformation.Options.Mode
    case 'TestGeneration'
        validator=Sldv.Validator.TestcaseValidator(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap);
    case 'DesignErrorDetection'
        validator=Sldv.Validator.CounterexampleValidatorInDed(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap);
    case 'PropertyProving'
        validator=Sldv.Validator.CounterexampleValidatorInPropertyProving(sldvData,model,objectiveToGoalMap,testcomp,goalIdToObjectiveIdMap);
    end

end



