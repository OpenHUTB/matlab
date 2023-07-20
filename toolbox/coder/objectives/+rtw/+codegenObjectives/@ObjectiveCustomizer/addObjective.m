function addObjective(obj,objective)




    objective.isObjIDDuplicated(objective.objectiveID);

    obj.nameToIDHash.put(objective.objectiveName,objective.objectiveID);
    obj.IDToNameHash.put(objective.objectiveID,objective.objectiveName);

    if isempty(objective.parameters)
        throw(MSLException([],message(...
        'Simulink:tools:noParamError',objective.objectiveName)));
    end

    cm=DAStudio.CustomizationManager;
    objective.customizationFileLocation=[cm.ObjectiveCustomizer.currentCustomizationFile,'/sl_customization.m'];
    obj.objective{end+1}=objective;
    objective.setOrder(length(obj.objective));
