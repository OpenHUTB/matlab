function validatePublicFunction(model,fcnName,varargin)




    fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);
    if isempty(fcnBlock)

        return;
    end

    [isPublic,~,~,~]=...
    coder.mapping.internal.isPublicSimulinkFunction(fcnBlock);
    if~isPublic
        return;
    end
    if isequal(get_param(fcnBlock,'BlockType'),'FunctionCaller')
        DAStudio.error(...
        'RTW:codeGen:PublicFunctionCallerSpecification',fcnName);
    end
end
