function out=getTargetMapping(model,fcnName)




    if~coder.mapping.internal.SimulinkFunctionMapping.isSimulinkModel(model)
        DAStudio.error('RTW:codeGen:InvalidModelFcnPrototype',model);
    end



    fcnBlock=...
    coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);

    if isempty(fcnBlock)
        DAStudio.error('RTW:codeGen:NoSLFcnOrCallerForFunctionName',...
        fcnName);
    end

    out=Simulink.CodeMapping.getCurrentMapping(model);
end
