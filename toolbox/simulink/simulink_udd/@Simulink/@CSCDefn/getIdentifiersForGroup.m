function retVal=getIdentifiersForGroup(hCSCDefn,hData)




    assert(hCSCDefn.IsGrouped);
    assert(isa(hData,'Simulink.Data'));



    retVal={};

    taObj=hCSCDefn.CSCTypeAttributes;
    if isempty(taObj)
        DAStudio.error('Simulink:dialog:NoTypeAttributesClassForGroupedCSC',...
        hCSCDefn.Name,hCSCDefn.OwnerPackage);
    end

    retStruct=taObj.getIdentifiersForGroup(hCSCDefn,hData);
    if~isscalar(retStruct)||~isstruct(retStruct)
        DAStudio.error('Simulink:dialog:CSCGroupIdentifiersMustBeValidStruct',...
        hCSCDefn.CSCTypeAttributesClassName);
    end


    identifiers=struct2cell(retStruct);
    if~iscellstr(identifiers)
        DAStudio.error('Simulink:dialog:CSCGroupIdentifiersMustBeValidStruct',...
        hCSCDefn.CSCTypeAttributesClassName);
    end

    if isempty(identifiers)

        DAStudio.error('Simulink:dialog:CSCGroupIdentifiersNotDefined',...
        hCSCDefn.CSCTypeAttributesClassName);
    end




    retVal=[fieldnames(retStruct)';identifiers'];


