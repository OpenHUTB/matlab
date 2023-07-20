






function[subStatus,subResult,violations]=checkBusNames(system,regexpBusNames,prefix,...
    reservedNames,conventionBusNames)
    violations=[];

    subStatus=true;

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Bus'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_DefinedIn')...
    ,Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Reason')});
    ft.setSubBar(false);


    parameters=Simulink.findVars(system,'SearchMethod','cached');
    filter=false(size(parameters));
    for index=1:numel(parameters)
        thisParameter=parameters(index);
        isModelPar=existsInGlobalScope(bdroot(system),thisParameter.Name);
        if isModelPar
            thisValue=safeEvalinGlobalScope(bdroot(system),thisParameter.Name);
            if isa(thisValue,'Simulink.Bus')
                filter(index)=true;
            end
        end
    end
    busObjects=parameters(filter);

    for index=1:numel(busObjects)
        thisName=busObjects(index).Name;
        thisValue=evalinGlobalScope(bdroot(system),thisName);
        for elementIndex=1:numel(thisValue.Elements)
            thisElement=thisValue.Elements(elementIndex);
            elementName=thisElement.Name;
            [isValid,issue,reason]=Advisor.Utils.Naming.isNameValid(elementName,regexpBusNames,...
            reservedNames,prefix,conventionBusNames);
            if~isValid
                subStatus=false;
                busElement=[thisName,'.',elementName];
                locationText=busObjects(index).SourceType;
                ft.addRow({busElement,issue,locationText,reason});
                dObj.Name=busElement;
                dObj.Source=locationText;
                dObj.SourceType=locationText;
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SimulinkVariableUsage',dObj);
                vObj.RecAction=issue;
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end

    subResult=ft;
end

function evaled_obj=safeEvalinGlobalScope(system,evalString)





    try
        evaled_obj=evalinGlobalScope(bdroot(system),evalString);
    catch
        evaled_obj=[];
    end
end
