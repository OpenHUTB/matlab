function parameters=evaluateParameters(parameters)
    assert(isstruct(parameters),'parameters must be a struct');
    for name=fieldnames(parameters)'
        name=name{:};%#ok<FXSET>
        parameters.(name)=locEvaluateParameter(name,parameters.(name));
    end
end

function result=locEvaluateParameter(name,parameter)
    paramName=parameter.Name.value;
    bPath=Simulink.BlockPath.fromPipePath(parameter.Path);
    paramPath=bPath.getLastPath();
    [result.value,exists]=slResolve(paramName,paramPath,'expression','startUnderMask');
    result.info='';
    if~exists
        result.error=sltest.assessments.internal.AssessmentsException(message('sltest:assessments:ParameterResolutionError',name,paramName,paramPath));
    else
        result.error=[];
        if bPath.getLength()>1
            paramModel=bdroot(paramPath);
            if~isempty(get_param(paramModel,'ParameterArgumentNames'))
                result.info=message('sltest:assessments:ParameterMightResolveToModelArguments',name,paramName,paramPath,paramModel,bPath.getBlock(bPath.getLength()-1)).getString();
            end
        end
    end
end
