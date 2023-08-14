function flattenedStr=validateAndReturnArgName(...
    modelName,designArgName,codeArgName,inOut)




    cs=getActiveConfigSet(modelName);
    try
        Simulink.ConfigSet.validateSymbol(cs,'CustomSymbolStrModelFcnArg',codeArgName);
    catch me
        switch me.identifier
        case 'Simulink:Engine:SfsTooLong'
            DAStudio.error('coderdictionary:api:IdentifierTooLong',codeArgName);
        otherwise
            rethrow(me);
        end
    end
    flattenedStr=slInternal('getIdentifierUsingNamingService',...
    modelName,codeArgName,designArgName,inOut);
    coder.mapping.internal.SimulinkFunctionMapping.checkFlattenedStr(flattenedStr,codeArgName);
end
