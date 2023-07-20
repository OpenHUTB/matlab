function setObjectiveID(obj,ID)




    obj.isObjIDDuplicated(ID);

    if~rtw.codegenObjectives.Objective.isValidID(ID)
        throw(MSLException([],message('Simulink:tools:invalidObjectiveID',ID)));
    end

    obj.objectiveID=convertStringsToChars(ID);
    obj.objectiveName=obj.objectiveID;
