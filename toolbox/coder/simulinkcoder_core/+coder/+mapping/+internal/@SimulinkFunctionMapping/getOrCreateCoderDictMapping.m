function modelmapping=getOrCreateCoderDictMapping(mdl)





    modelmapping=Simulink.CodeMapping.getCurrentMapping(mdl);
    if isempty(modelmapping)

        configSet=getActiveConfigSet(mdl);
        coder.mapping.internal.create(...
        mdl,configSet);
        modelmapping=Simulink.CodeMapping.getCurrentMapping(mdl);
    end

    if isempty(modelmapping.SimulinkFunctionCallerMappings)
        modelmapping.sync_SlFunctionAndCallers();
    end
end
