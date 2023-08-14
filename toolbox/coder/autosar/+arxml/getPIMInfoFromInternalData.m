function[varAccess,ARPIMVarName,PIMDataTypeName,rteDataTypeName]=getPIMInfoFromInternalData(internalData,maxShortNameLength)













    switch(class(internalData.Implementation))
    case{'RTW.Variable','coder.descriptor.Variable'}
        PIMVarName=internalData.Implementation.Identifier;
        type=internalData.Implementation.Type;
        varAccess=sprintf('&%s',PIMVarName);
    case{'RTW.PointerVariable','coder.descriptor.PointerVariable'}
        PIMVarName=internalData.Implementation.Identifier;
        type=internalData.Implementation.TargetVariable.Type;
        varAccess=sprintf('%s',PIMVarName);
    case{'RTW.PointerExpression','coder.descriptor.PointerExpression'}
        PIMVarName=internalData.Implementation.TargetRegion.Identifier;
        type=internalData.Implementation.TargetRegion.Type;
        varAccess=sprintf('&%s',PIMVarName);
    otherwise
        autosar.mm.util.MessageReporter.createWarning('RTW:autosar:unrecognisedInternalDataType',...
        class(internalData.Implementation));
    end

    PIMDataTypeName=type.Identifier;

    ARPIMVarName=arxml.arxml_private('p_create_aridentifier',PIMVarName,...
    maxShortNameLength);


    rteDataTypeName=sprintf('%s_type',PIMDataTypeName);
