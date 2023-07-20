function groups=getDefaultPropertyGroups(systemName)




    if matlab.system.display.internal.DataTypesGroup.hasDataTypes(systemName)
        mainGroup=matlab.system.display.SectionGroup(systemName);
        datatypesGroup=matlab.system.display.internal.DataTypesGroup(systemName);
        groups=[mainGroup,datatypesGroup];
    else
        groups=matlab.system.display.Section(systemName);
    end