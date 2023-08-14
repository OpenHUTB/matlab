function values=getEnumerationCustomStrings(metaProp)






    canBeCustomized=matlab.system.internal.isRestrictedToScalarEnumeration(metaProp);

    if~canBeCustomized
        values=strings(0);
        return
    end

    enumMetaClass=metaProp.Validation.Class;

    if metaProp.EnumerationUsingDisplayStrings
        stringFcn=str2func(enumMetaClass.Name+".displayStrings");
        values=stringFcn();

        if~((isstring(values)||iscellstr(values))...
            &&isvector(values)...
            &&(numel(values)==numel(enumMetaClass.EnumerationMemberList)))
            error(message('MATLAB:system:Enumeration:InvalidDisplayStrings',...
            class(enumMetaClass.Name)));
        end

        if length(values)~=length(unique(lower(values)))
            error(message('MATLAB:system:Enumeration:InvalidDuplicateDisplayStrings',...
            class(enumMetaClass.Name)));
        end

    elseif metaProp.EnumerationUsingMessageCatalog
        stringFcn=str2func(enumMetaClass.Name+".messageIdentifiers");
        messageIDs=stringFcn();

        if~((isstring(messageIDs)||iscellstr(messageIDs))...
            &&isvector(messageIDs)...
            &&(numel(messageIDs)==numel(enumMetaClass.EnumerationMemberList)))
            error(message('MATLAB:system:Enumeration:InvalidMessageIdentifiers',...
            class(enumMetaClass.Name)));
        end

        values=matlab.system.internal.lookupMessageCatalogEntries(messageIDs,true,'enumeration');

        if length(values)~=length(unique(lower(values)))
            error(message('MATLAB:system:Enumeration:InvalidDuplicateCatalogStrings',...
            class(enumMetaClass.Name)));
        end

    else
        values=strings(0);
    end
end
