




function[vars,errorMessages]=findVars(modelName,harnessName,overrideVariables)
    len=length(overrideVariables);
    vars=cell(1,len);
    currentIndex=1;
    errorMessages={};


    if len==0
        return;
    end

    load_system(modelName);
    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);
    oc=onCleanup(@()cleanupFunction(currHarness,deactivateHarness,oldHarness,wasHarnessOpen));


    try
        currModelStatus=get_param(modelToUse,'SimulationStatus');

        if(strcmpi(currModelStatus,'stopped'))
            searchMethod='compiled';
        else

            searchMethod='cached';
        end
        variableUsage=stm.internal.MRT.share.MRTFindVar(modelToUse,'SearchMethod',searchMethod);
    catch me
        errorMessages{1}=me.message;
        numCauses=length(me.cause);
        for j=1:numCauses
            [tempErrors,~]=stm.internal.util.getMultipleErrors(me.cause{j});
            errorMessages=[errorMessages,tempErrors];%#ok
        end
        return;
    end


    varMap=containers.Map;
    for i=1:len
        varMap(overrideVariables(i).name)=true;
    end


    len=length(variableUsage);
    for i=len:-1:1
        if(~varMap.isKey(variableUsage(i).Name))
            variableUsage(i)=[];
        end
    end


    len=length(variableUsage);
    for i=1:len
        varUsage=variableUsage(i);
        var=setFields(varUsage);

        if(isstruct(var))
            vars{currentIndex}=var;
            currentIndex=currentIndex+1;
        end
    end




    for i=1:len
        if(varMap.isKey(variableUsage(i).Name))
            varMap.remove(variableUsage(i).Name);
        end
    end



    count=varMap.Count;
    names=keys(varMap);
    for i=1:count
        obj=struct;
        obj.Name=names{i};
        vars{currentIndex}=obj;
        currentIndex=currentIndex+1;
    end
end

function cleanupFunction(currHarness,deactivateHarness,oldHarness,wasHarnessOpen)
    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end

function var=setFields(variableUsage)
    var=struct('Name',{variableUsage.Name},'Source',{variableUsage.Source},...
    'SourceType',{variableUsage.SourceType},'Users',{variableUsage.Users});

    if(strcmp(variableUsage.SourceType,'mask workspace'))

        var.SIDFullString=get_param(variableUsage.Source,'SIDFullString');
        var.Users={var.Source};
    elseif(strcmp(variableUsage.SourceType,'data dictionary'))

        obj=struct(var);
        obj.DataDictionaryPath=which(var.Source);
        var=obj;
    end
end
