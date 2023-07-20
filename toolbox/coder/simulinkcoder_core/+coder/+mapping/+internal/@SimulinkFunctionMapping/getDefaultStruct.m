function out=getDefaultStruct(model,fcnName)




    import coder.mapping.internal.*;
    fcnBlock=SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);
    out.CodePrototype=...
    SimulinkFunctionMapping.createDefaultFunctionPrototypeFromBlock(...
    fcnBlock,true);
end
