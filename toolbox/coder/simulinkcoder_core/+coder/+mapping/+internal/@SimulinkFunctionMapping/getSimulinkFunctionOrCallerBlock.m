function fcnBlock=getSimulinkFunctionOrCallerBlock(model,fcnName)






    fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionBlock(...
    model,fcnName);

    if isempty(fcnBlock)
        fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getFunctionCallerBlock(...
        model,fcnName);
    end
end
