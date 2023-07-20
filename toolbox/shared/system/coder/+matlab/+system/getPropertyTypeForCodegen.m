function propType=getPropertyTypeForCodegen(className,propName)






    propType='';
    mc=meta.class.fromName(className);
    mp=findobj(mc.PropertyList,'-depth',1,'Name',propName);

    if isempty(mp)||~isa(mp,'matlab.system.CustomMetaProp')
        return
    end

    if mp.Logical
        propType='Logical';
    elseif mp.PositiveInteger
        propType='PositiveInteger';
    elseif mp.ConstrainedSet
        if matlab.system.display.internal.DataTypesGroup.isDataTypeSetPropertyForCodegen(propName,mc)
            propType='DataTypeSet';
        else
            propType='StringSet';
        end
    elseif~isempty(mp.MustBeMember)
        propType='StringSet';
    elseif mp.DynamicEnumeration||mp.EnumerationUsingDisplayStrings||mp.EnumerationUsingMessageCatalog
        propType='CustomizedEnumeration';
    end
end
