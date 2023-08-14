function funcObj=setPrototype(model,fcnName,coderDictMapping,fcnPrototype,funcObj)





    import coder.mapping.internal.*;

    if isempty(fcnPrototype)

        set_param(model,'Dirty','on');
        coderDictMapping.removeSimulinkFunctionMapping(fcnName);
        return;
    end

    fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);

    if isempty(fcnBlock)

        DAStudio.error(...
        'RTW:codeGen:NoSLFcnOrCallerForFunctionName',fcnName);
    end


    SimulinkFunctionMapping.validateFunctionPrototype(model,fcnBlock,...
    fcnPrototype,false);
    oldFuncPrototype=SimulinkFunctionMapping.getField(model,fcnName,'CodePrototype');


    if isempty(oldFuncPrototype)||~strcmp(fcnPrototype,oldFuncPrototype)

        set_param(model,'Dirty','on');
        if isempty(funcObj)
            funcObj=SimulinkFunctionMapping.getOrCreateFunctionPrototypeObj(fcnName,coderDictMapping);
        end
        funcObj.Prototype=fcnPrototype;
    end
end
