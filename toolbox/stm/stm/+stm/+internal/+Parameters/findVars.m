



function[vars,errorMessages]=findVars(modelName,harnessName,parameters)
    vars={};
    errorMessages={};
    if isempty(parameters)
        return;
    end

    load_system(modelName);
    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=...
    stm.internal.util.resolveHarness(modelName,harnessName);
    oc=onCleanup(@()cleanupFunction(currHarness,deactivateHarness,oldHarness,wasHarnessOpen));


    try
        args=stm.internal.Parameters.getFindVarsArgs(modelToUse);
        variableUsage=stm.internal.MRT.share.MRTFindVar(modelToUse,args{:});
    catch me
        errorMessages{1}=me.message;
        for j=1:length(me.cause)
            tempErrors=stm.internal.util.getMultipleErrors(me.cause{j});
            errorMessages=[errorMessages,tempErrors];%#ok
        end
        return;
    end

    [varUsage,variableUsage]=stm.internal.Parameters.getVarUsage(variableUsage,modelToUse,modelName);
    parameters=getParameterInfoStruct(parameters);
    overrideVariables=getOverrideVariables(parameters,modelToUse);


    foundIdx=ismember(varUsage,overrideVariables);
    variableUsage(~foundIdx)=[];


    for i=1:length(variableUsage)
        var=setFields(variableUsage(i));

        if(isstruct(var))
            vars{end+1}=var;
        end
    end


    varUsage=stm.internal.Parameters.getVarUsage(variableUsage,modelToUse,modelName);
    foundIdx=ismember(overrideVariables,varUsage);
    undefinedVars=overrideVariables(~foundIdx);


    if~isempty(undefinedVars)
        newVars=struct('Name',undefinedVars.extractBefore('/').cellstr,...
        'SourceType',cellstr(getSourceType(undefinedVars,modelToUse)),...
        'Source',undefinedVars.extractAfter('/').cellstr,'IsMisaligned',true);
        vars=[vars,num2cell(newVars)];
    end
end

function cleanupFunction(currHarness,deactivateHarness,oldHarness,wasHarnessOpen)
    if~isempty(currHarness)
        useMultipleHarnessOpen=0;
        try
            useMultipleHarnessOpen=stm.internal.util.getFeatureFlag('MultipleHarnessOpen');
        catch me
            if~(isequal(me.identifier,'sl_feature:utils:InvCallForFeatureName')||...
                isequal(me.identifier,'Simulink:Engine:InvCallForFeatureName'))
                rethrow(me);
            end
        end
        if useMultipleHarnessOpen==0
            close_system(currHarness.name,0);

            if deactivateHarness
                stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
            end
        end
    end
end

function var=setFields(variableUsage)
    var=struct('Name',variableUsage.Name,'Source',variableUsage.Source,...
    'SourceType',variableUsage.SourceType,'Users',{variableUsage.Users},...
    'TopModel',variableUsage.TopModel);

    if strcmp(variableUsage.SourceType,'mask workspace')

        var.SIDFullString=get_param(variableUsage.Source,'SIDFullString');
        var.Users={var.Source};
    elseif strcmp(variableUsage.SourceType,'data dictionary')

        var.DataDictionaryPath=which(var.Source);
    end
end

function overrideVariables=getOverrideVariables(po,modelToUse)

    models=string({po.ModelReference});
    models(models.strlength==0)=modelToUse;
    overrideVariables={po.Name}+"/"+models;
end

function strct=getParameterInfoStruct(parameters)
    if isnumeric(parameters)

        po=sltest.internal.Helper.getParameterOverride(parameters);
        strct=struct('Name',{po.Name},'ModelReference',{po.Workspace});
    else


        strct=struct('Name',{parameters.name},'ModelReference','');
    end
end

function sourceType=getSourceType(vars,modelToRun)
    sourceType=strings(size(vars));
    idx=vars.extractAfter('/')~=modelToRun;
    sourceType(idx)='model workspace';
end
