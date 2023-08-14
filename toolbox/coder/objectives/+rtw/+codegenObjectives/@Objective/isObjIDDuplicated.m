function isObjIDDuplicated(ID)




    if nargin>0
        ID=convertStringsToChars(ID);
    end

    cm=DAStudio.CustomizationManager;

    for i=1:length(cm.ObjectiveCustomizer.objective)
        if strcmp(ID,cm.ObjectiveCustomizer.objective{i}.objectiveID)
            throw(MSLException([],message('Simulink:tools:duplicatedObjID',ID)));
        end
    end

    for i=1:length(cm.ObjectiveCustomizer.factoryObjectives)
        if strcmp(ID,cm.ObjectiveCustomizer.factoryObjectives{i}.objectiveID)
            throw(MSLException([],message('Simulink:tools:duplicatedObjID',ID)));
        end
    end
