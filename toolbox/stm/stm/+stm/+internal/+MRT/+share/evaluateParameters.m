function parameters=evaluateParameters(parameters)




    assert(isstruct(parameters),'parameters must be a struct');
    for name=fieldnames(parameters)'
        name=name{:};%#ok<FXSET>
        parameters.(name)=locEvaluateParameter(name,parameters.(name));
    end
end

function result=locEvaluateParameter(name,parameter)
    paramName=parameter.Name.value;
    if~isempty(which('Simulink.BlockPath.fromPipePath'))
        bPath=Simulink.BlockPath.fromPipePath(parameter.Path);
    else
        bPath=stm.internal.MRT.share.FromPipePath(parameter.Path);
    end

    paramPath=bPath.getLastPath();
    [result.value,exists]=slResolve(paramName,paramPath,'expression','startUnderMask');
    result.info='';
    if~exists
        result.error=MException('sltest:assessments:ParameterResolutionError',...
        stm.internal.MRT.share.getString('stm:MultipleReleaseTesting:AssessmentsParameterResolutionError',...
        name,paramName,paramPath));
    else
        result.error=[];
        if bPath.getLength()>1
            paramModel=bdroot(paramPath);
            if~isempty(get_param(paramModel,'ParameterArgumentNames'))
                result.info=...
                stm.internal.MRT.share.getString(...
                'stm:MultipleReleaseTesting:AssessmentsParameterMightResolveToModelArguments',...
                name,paramName,paramPath,paramModel,...
                bPath.getBlock(bPath.getLength()-1));
            end
        end
    end
end