function notifyInvalidEnum(elem,propDef)




    mdlName=elem.getTopLevelArchitecture.getName;

    ZCStudio.makeZcFixitNotification(mdlName,'InvalidEnum',...
    'SystemArchitecture:zcFixitWorkflows:InvalidEnumStudioNotification',...
    'warn',propDef.fullyQualifiedName);

end