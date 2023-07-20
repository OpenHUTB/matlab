function checkFlattenedStr(flattenedStr,symbol)





    if isempty(flattenedStr)
        if~contains(symbol,'$M')
            DAStudio.error('SimulinkCoderApp:slfpc:ResolvedIdentifierIsEmpty');
        end
    else


        if~coder.mapping.internal.SimulinkFunctionMapping.isValidIdentifier(flattenedStr)&&...
            length(symbol)>1&&strcmp(symbol(1:2),'$U')
            DAStudio.error('SimulinkCoderApp:slfpc:ResolvedIdentifierIsInvalid');
        end
    end
end
