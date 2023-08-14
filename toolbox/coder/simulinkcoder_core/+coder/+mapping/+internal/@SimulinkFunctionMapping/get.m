function out=get(model,fcnName)





    import coder.mapping.internal.*;

    cTargetMapping=SimulinkFunctionMapping.getTargetMapping(model,fcnName);
    funcObj=SimulinkFunctionMapping.getFunctionObj(cTargetMapping,fcnName);

    if~isempty(funcObj)
        out.CodePrototype=funcObj.MappedTo.Prototype;
    else


        out=SimulinkFunctionMapping.getDefaultStruct(model,fcnName);
    end
end
