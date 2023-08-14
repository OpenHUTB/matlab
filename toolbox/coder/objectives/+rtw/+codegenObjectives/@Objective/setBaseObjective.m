function setBaseObjective(obj,bsObj)




    if iscell(bsObj)
        throw(MSLException([],message(...
        'Simulink:tools:invalidBaseObjectiveAsCell')));
    end
    bsObj=convertStringsToChars(bsObj);


    obj.baseObjective=bsObj;
    foundObj=[];

    cm=DAStudio.CustomizationManager;
    custmzr=cm.ObjectiveCustomizer;


    for i=1:length(custmzr.factoryObjectives)
        objective=custmzr.factoryObjectives{i};

        if strcmp(bsObj,objective.objectiveID)
            foundObj=objective;
            break;
        end
    end


    if isempty(foundObj)
        for i=1:length(custmzr.objective)
            objective=custmzr.objective{i};

            if strcmp(bsObj,objective.objectiveID)
                foundObj=objective;
                break;
            end
        end
    end

    if isempty(foundObj)
        throw(MSLException([],message(...
        'Simulink:tools:invalidBaseObjective',bsObj)));
    end





    for j=1:length(foundObj.parameters)
        name=foundObj.parameters{j}.name;
        value=foundObj.parameters{j}.value;
        obj.parameters{j}=rtw.codegenObjectives.Parameter(name,value,obj.objectiveName);

        obj.paramHash.put(name,value);
        obj.paramHashPos.put(name,length(obj.parameters));
    end


    for j=1:length(foundObj.checks)
        MAC=foundObj.checks{j}.MAC;
        setting=foundObj.checks{j}.setting;
        obj.checks{j}=rtw.codegenObjectives.Check(MAC,setting);

        obj.checkHash.put(MAC,setting);
        obj.checkHashPos.put(MAC,length(obj.checks));
    end
