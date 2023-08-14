function[vars,errorMessages]=findRealTimeVars(modelName,harnessName,overrideVariables,loadApplicationFrom,targetApplication,targetName)

    len=length(overrideVariables);
    vars=cell(1,len);
    currentIndex=1;
    errorMessages={};


    if len==0
        return;
    end

    try
        parameterSet=stm.internal.genericrealtime.getParameters(modelName,harnessName,loadApplicationFrom,targetApplication,targetName);
        overrideNames=string(overrideVariables);
        parameterNames=string({parameterSet.Name});

        overridenParameters=parameterSet(ismember(parameterNames,overrideNames));


        len=length(overridenParameters);
        for idx=1:len
            par=overridenParameters(idx);
            var=struct('Name',{par.Name},'Source',{par.Source},...
            'SourceType',{par.SourceType},'Users',{par.ModelElement});
            vars{currentIndex}=var;
            currentIndex=currentIndex+1;









            if(strfind(var.Source,newline))
                var.Source=replace(var.Source,newline,' ');
                vars{currentIndex}=var;
                currentIndex=currentIndex+1;
            end
        end


        invalidParams=overrideNames(~ismember(overrideNames,parameterNames));
        len=numel(invalidParams);
        for idx=1:len
            var=struct('Name',{char(invalidParams(idx))},'NotFound',{true});
            vars{currentIndex}=var;
            currentIndex=currentIndex+1;
        end
    catch me
        errorMessages{1}=me.message;
        numCauses=length(me.cause);
        for j=1:numCauses
            [tempErrors,~]=stm.internal.util.getMultipleErrors(me.cause{j});
            errorMessages=[errorMessages,tempErrors];%#ok
        end
        return;
    end
end
