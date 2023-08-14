function result=setUpInSessionModel(modelfile,modelArgs,startT,stopT,setupScript)

    if~isempty(setupScript)
        [~,filename,~]=fileparts(setupScript);
        evalin('base',['run ',filename]);
    end

    result=struct('handle','');
    [~,model,~]=fileparts(modelfile);

    if(bdIsLoaded(model))
        result.isLoaded=true;
        modelHandle=get_param(model,'Handle');
    else
        result.isLoaded=false;
        modelHandle=load_system(modelfile);
    end

    if(~isempty(modelArgs))
        modelWorkspace=get_param(modelHandle,'ModelWorkspace');
        allParams=Simulink.internal.getModelParameterInfo(modelHandle);
        [~,num]=size(modelArgs);
        for i=1:num
            paramName=modelArgs(i).name;

            hasParamName=cellfun(@(param)strcmp(param.Name,modelArgs(i).name),allParams);

            if(~any(hasParamName))

                ME=MException("Simulink:Data:WksUndefinedVariable",...
                "Undefined variable '%s' workspace ('%s').",paramName,model);
                throw(ME);
            end


            idx=find(hasParamName);
            try
                paramVal=evalin(modelWorkspace,modelArgs(i).value);
            catch ME

                if ischar(modelArgs(i).value)||isstring(modelArgs(i).value)
                    paramVal=modelArgs(i).value;
                else
                    rethrow(ME);
                end
            end
            if isequal(allParams{idx}.Type,"ParameterObject")
                setVariablePart(modelWorkspace,[paramName,'.Value'],paramVal);
            elseif isequal(allParams{idx}.Type,"Variable")
                assignin(modelWorkspace,paramName,paramVal);
            end
        end
    end

    set_param(modelHandle,'StartTime',num2str(startT));
    set_param(modelHandle,'StopTime',num2str(stopT));

    result.handle=modelHandle;
end
