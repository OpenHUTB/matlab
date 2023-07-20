function isObjNameDuplicated(name)




    if nargin>0
        name=convertStringsToChars(name);
    end

    cm=DAStudio.CustomizationManager;

    for i=1:length(cm.ObjectiveCustomizer.objective)
        if strcmp(name,cm.ObjectiveCustomizer.objective{i}.objectiveName)
            throw(MSLException([],message('Simulink:tools:duplicatedObjName',name)));
        end
    end

    for i=1:length(cm.ObjectiveCustomizer.factoryObjectives)
        if strcmp(name,cm.ObjectiveCustomizer.factoryObjectives{i}.objectiveName)
            throw(MSLException([],message('Simulink:tools:duplicatedObjName',name)));
        end
    end
