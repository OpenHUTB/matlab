function[out,configsetSymbol]=getFcnName(blk,fcnName,codeName)




    modelName=bdroot(blk);
    if coder.mapping.internal.SimulinkFunctionMapping.isPublicFcn(blk,fcnName)
        configsetSymbol=coder.mapping.internal.SimulinkFunctionMapping.getNamingRuleFromMappingDefaults(modelName);
        if isempty(configsetSymbol)



            configsetSymbol=get_param(modelName,'CustomSymbolStrModelFcn');
        end
    else
        configsetSymbol='$N';
    end

    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
    if strcmp(mappingType,'CppModelMapping')
        configsetSymbol='$N';
    end
    if coder.mapping.internal.SimulinkFunctionMapping.isPublicFcn(blk,fcnName)

        out=slInternal('getIdentifierUsingNamingService',...
        modelName,configsetSymbol,fcnName);
    else
        out=codeName;
    end
end
