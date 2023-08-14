function properties=getPropertyListNotUsedInDerivedClass(systemName,paramPresentInMask)
    sysMetaClass=meta.class.fromName(systemName);
    metaProperties=sysMetaClass.PropertyList;
    classInfoWithAllPropsFromBaseAndDerivedClass=matlab.system.display.internal.getDefaultPropertyGroups(systemName);
    allPropNamesFromBaseAndDerivedClass=classInfoWithAllPropsFromBaseAndDerivedClass.PropertyList;

    properties=matlab.system.display.internal.Property.empty;
    for i=1:length(allPropNamesFromBaseAndDerivedClass)
        if~ismember(allPropNamesFromBaseAndDerivedClass{i},paramPresentInMask)&&...
            ~strcmpi(allPropNamesFromBaseAndDerivedClass{i},'SimulateUsing')
            property=matlab.system.display.internal.Property(allPropNamesFromBaseAndDerivedClass{i});
            property=property.setAttributes(metaProperties);
            properties=[properties,property];
        end

    end
