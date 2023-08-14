function funcObj=getOrCreateFunctionPrototypeObj(fcnName,coderDictMapping)





    import coder.mapping.internal.*;

    isCpp=isa(coderDictMapping,'Simulink.CppModelMapping.ModelMapping');

    funcMappingObj=SimulinkFunctionMapping.getFunctionObj(coderDictMapping,fcnName);

    if isempty(funcMappingObj)
        if isCpp
            funcObj=Simulink.CppModelMapping.FunctionPrototype;
        else
            funcObj=Simulink.CoderDictionary.FunctionPrototype;
        end
    else
        funcObj=funcMappingObj.MappedTo;
        if isempty(funcObj)
            if isCpp
                funcObj=Simulink.CppModelMapping.FunctionPrototype;
            else
                funcObj=Simulink.CoderDictionary.FunctionPrototype;
            end
        end
    end
end
