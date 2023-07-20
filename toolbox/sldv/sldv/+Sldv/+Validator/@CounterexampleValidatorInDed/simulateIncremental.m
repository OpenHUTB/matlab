




function[simData,errorDetectionObjValidator,isActiveLogicTC]=simulateIncremental(obj,testCases)
    testComp=obj.testComp;
    sldvDataTCs=[];
    tcIdx=[];
    noopValidatedTcIdx=[];
    isActiveLogicTC=true;

    for tcNum=1:length(testCases)



        for goalNum=1:length(testCases(tcNum).goals)
            goal=testCases(tcNum).goals(goalNum);
            goalId=goal.getGoalMapId();
            if(obj.goalIdToObjectiveMap.isKey(goalId))
                objectiveId=obj.goalIdToObjectiveMap(goalId);
                obj.sldvData.Objectives(objectiveId).status='Undecided';
            end
        end

        currentSldvDataTC=Sldv.DataUtils.convertTestCasesToSldvDataFormat(testCases(tcNum),obj.modelH,...
        testComp,obj.sldvData.Objectives,...
        obj.goalIdToObjectiveMap);


        covObjTc=filterOutIfNotActiveLogicTC(obj,currentSldvDataTC);
        diagObjsTc=filterOutIfNotErrorDetection(obj,currentSldvDataTC);

        if~isempty(covObjTc)
            sldvDataTCs=[sldvDataTCs,covObjTc];%#ok<AGROW> 
            tcIdx=[tcIdx,tcNum];%#ok<AGROW>
        elseif~isempty(diagObjsTc)
            sldvDataTCs=[sldvDataTCs,diagObjsTc];%#ok<AGROW>
            tcIdx=[tcIdx,tcNum];%#ok<AGROW>
            isActiveLogicTC=false;
            obj.diagValidatationObjectives{tcIdx}=[diagObjsTc.objectives.objectiveIdx];
        else
            noopValidatedTcIdx=[noopValidatedTcIdx,tcNum];%#ok<AGROW>
        end
    end

    obj.tcIdx=tcIdx;
    obj.noopValidatedTcIdx=noopValidatedTcIdx;
    obj.tcObjectiveIndices=arrayfun(@(testcase){arrayfun(@(object)object.objectiveIdx,testcase.objectives)},sldvDataTCs);
    [simData,errorDetectionObjValidator]=obj.simulateTestCases(sldvDataTCs);
    return;
end

function currentSldvDataTC=filterOutIfNotActiveLogicTC(obj,currentSldvDataTC)
    if isempty(currentSldvDataTC);return;end
    structCovObjKinds=Sldv.utils.getStructuralCoverageObjectiveTypes();
    objectives=[currentSldvDataTC.objectives.objectiveIdx];
    isActiveLogicTc=false;
    for objIdx=1:length(objectives)
        if any(strcmp(obj.sldvData.Objectives(objectives(objIdx)).type,structCovObjKinds))
            isActiveLogicTc=true;
            break;
        end
    end

    if~isActiveLogicTc
        currentSldvDataTC=[];
    end
end


function currentSldvDataTC=filterOutIfNotErrorDetection(obj,currentSldvDataTC)


    if isempty(currentSldvDataTC);return;end
    if~slavteng('feature','DedValidation')


        currentSldvDataTC=[];
        return;
    end
    structDiagObjKinds=Sldv.Utils.getDiagnosticsBasedObjectiveTypes();
    objectives=[currentSldvDataTC.objectives.objectiveIdx];
    iserrorDetectionObj=false;
    for objIdx=1:length(objectives)
        if any(strcmp(obj.sldvData.Objectives(objectives(objIdx)).type,structDiagObjKinds))
            iserrorDetectionObj=true;
            break;
        end
    end

    if~iserrorDetectionObj
        currentSldvDataTC=[];
    end
end
