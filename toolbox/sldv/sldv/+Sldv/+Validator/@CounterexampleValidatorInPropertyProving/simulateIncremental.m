


function simulateIncremental(obj,counterExamples)
    validatedCounterExamples=[];%#ok<NASGU>
    sldvDataCEs=[];
    testComp=obj.testComp;




    for ceNum=1:length(counterExamples)
        for goalNum=1:length(counterExamples(ceNum).goals)
            goal=counterExamples(ceNum).goals(goalNum);
            goalId=goal.getGoalMapId();
            if(obj.goalIdToObjectiveMap.isKey(goalId))
                objectiveId=obj.goalIdToObjectiveMap(goalId);
                obj.sldvData.Objectives(objectiveId).status='Undecided';
            end
        end
    end

    for ceNum=1:length(counterExamples)
        currentSldvDataCE=Sldv.DataUtils.convertTestCasesToSldvDataFormat(counterExamples(ceNum),obj.modelH,...
        testComp,obj.sldvData.Objectives,...
        obj.goalIdToObjectiveMap);

        if~isempty(currentSldvDataCE)
            sldvDataCEs=[sldvDataCEs,currentSldvDataCE];%#ok<AGROW> 
        end
    end

    obj.simulateCounterExamples(sldvDataCEs);
end
