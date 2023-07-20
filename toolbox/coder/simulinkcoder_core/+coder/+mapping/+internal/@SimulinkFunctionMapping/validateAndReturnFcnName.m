function flattenedStr=validateAndReturnFcnName(modelName,fcnName,codeFcnName)




    if isempty(codeFcnName)
        DAStudio.error('coderdictionary:api:EmptyFunctionName',fcnName);
    end


    cs=getActiveConfigSet(modelName);
    try
        Simulink.ConfigSet.validateSymbol(cs,'CustomSymbolStrModelFcn',codeFcnName);
    catch me
        switch me.identifier
        case 'Simulink:Engine:SfsTooLong'
            DAStudio.error('coderdictionary:api:IdentifierTooLong',codeFcnName);
        otherwise
            rethrow(me);
        end
    end


    flattenedStr=slInternal('getIdentifierUsingNamingService',...
    modelName,codeFcnName,fcnName);
    coder.mapping.internal.SimulinkFunctionMapping.checkFlattenedStr(flattenedStr,codeFcnName);
end
