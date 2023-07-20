function setParamForSLModelActor(modelfile,modelArgs)

    if(isempty(modelfile)||isempty(modelArgs))
        return;
    end

    [~,model,~]=fileparts(modelfile);
    modelHandle=get_param(model,'Handle');
    modelWorkspace=get_param(model,"ModelWorkspace");
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
    set_param(model,'SimulationCommand','Update');

end