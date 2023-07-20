function hasISP=hasInstanceSpecificProperties(hCSCDefn,hDataObj)




    hasISP=false;


    if strcmp(hCSCDefn.CSCType,'FlatStructure')
        if hCSCDefn.CSCTypeAttributes.IsStructNameInstanceSpecific
            hasISP=true;
        end
    elseif hCSCDefn.IsMemorySectionInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsHeaderFileInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsDataScopeInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsDataInitInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsDataAccessInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsOwnerInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.PreserveDimensionsInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsDefinitionFileInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsReusableInstanceSpecific
        hasISP=true;
    elseif hCSCDefn.IsConcurrentAccessInstanceSpecific
        hasISP=true;
    elseif~isempty(hCSCDefn.CSCTypeAttributes)

        hasISP=~isempty(hCSCDefn.CSCTypeAttributes.getInstanceSpecificProps);
    end



