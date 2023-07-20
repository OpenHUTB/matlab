




function simData=simulateIncremental(obj,testCases)
    testComp=obj.testComp;
    sldvDataTCs=[];
    tcIdx=[];
    noopValidatedTcIdx=[];

    for tcNum=1:length(testCases)



        for goalNum=1:length(testCases(tcNum).goals)
            goal=testCases(tcNum).goals(goalNum);
            goalId=goal.getGoalMapId();
            if(obj.goalIdToObjectiveMap.isKey(goalId))
                objectiveId=obj.goalIdToObjectiveMap(goalId);
                obj.sldvData.Objectives(objectiveId).status='Undecided';
            end
        end

        if(Sldv.utils.isPathBasedTestGeneration(testComp.activeSettings))
            currentSldvDataTC=Sldv.DataUtils.convertTestCasesToSldvDataFormat(testCases(tcNum),obj.modelH,...
            testComp,obj.sldvData.Objectives,...
            obj.goalIdToObjectiveMap);
        else
            currentSldvDataTC=Sldv.DataUtils.convertTestCasesToSldvDataFormat(testCases(tcNum),obj.modelH,...
            testComp,obj.sldvData.Objectives,...
            obj.goalIdToObjectiveMap);
        end

        if~isempty(currentSldvDataTC)
            sldvDataTCs=[sldvDataTCs,currentSldvDataTC];%#ok<AGROW> 
            tcIdx=[tcIdx,tcNum];%#ok<AGROW>
        else
            noopValidatedTcIdx=[noopValidatedTcIdx,tcNum];%#ok<AGROW>
        end
    end

    obj.tcIdx=tcIdx;
    obj.noopValidatedTcIdx=noopValidatedTcIdx;
    obj.tcObjectiveIndices=arrayfun(@(testcase){arrayfun(@(object)object.objectiveIdx,testcase.objectives)},sldvDataTCs);
    simData=obj.simulateTestCases(sldvDataTCs);

    return;
end
