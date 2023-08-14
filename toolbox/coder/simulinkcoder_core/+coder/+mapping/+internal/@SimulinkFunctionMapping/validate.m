function validate(model,fcnName)




    import coder.mapping.internal.*;

    cTargetMapping=SimulinkFunctionMapping.getTargetMapping(model,fcnName);
    funcMappingObj=SimulinkFunctionMapping.getFunctionObj(cTargetMapping,fcnName);




    if isempty(funcMappingObj)
        return;
    end
    if isempty(funcMappingObj.MappedTo)
        DAStudio.error('coderdictionary:api:NoMappedTo',fcnName);
    end

    fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);

    if isempty(fcnBlock)

        DAStudio.error(...
        'RTW:codeGen:NoSLFcnOrCallerForFunctionName',fcnName);
    end

    SimulinkFunctionMapping.validateFunctionPrototype(model,fcnBlock,...
    funcMappingObj.MappedTo.Prototype,false);
end
