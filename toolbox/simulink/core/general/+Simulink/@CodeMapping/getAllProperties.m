function[props,isMapped]=getAllProperties(modelH,mappingObj)






    props={};
    hasMappingAndComSpecs=false;
    if(isa(mappingObj,'Simulink.CoderDictionary.FunctionMapping')...
        ||isa(mappingObj,'Simulink.CoderDictionary.BlockFcnMapping'))...
        &&isprop(mappingObj,'FunctionReference')
        props{end+1}='FunctionClass';
        props{end+1}='MemorySection';
        if slfeature('InternalDataMemorySectionInCMapping')>0
            props{end+1}='InternalDataMemorySection';
        end
    elseif(isa(mappingObj,'Simulink.CppModelMapping.InportsMapping')...
        ||isa(mappingObj,'Simulink.CppModelMapping.OutportsMapping'))
        if strcmp(mappingObj.MessageCustomizationKind,'POSIX Message')

            props{end+1}='MqName';
            props{end+1}='Priority';
            props{end+1}='MaxMsgNum';
        elseif strcmp(mappingObj.MessageCustomizationKind,'DDS Message')

            props{end+1}='ReaderXMLTag';
            props{end+1}='WriterXMLTag';
            props{end+1}='Topic';
            props{end+1}='ConfigurationMode';
            props{end+1}='ReaderQoS';
            props{end+1}='WriterQoS';
            props{end+1}='FilterKind';
            props{end+1}='FilterExpression';
            props{end+1}='FilterParameterList';
        end
    elseif(isa(mappingObj,'Simulink.CppModelMapping.FunctionMapping')...
        ||isa(mappingObj,'Simulink.CppModelMapping.BlockFcnMapping'))...
        &&isprop(mappingObj,'Prototype')
        props{end+1}='CppPrototype';
        props{end+1}='CppMethod';
    end

    if isprop(mappingObj,'MappedTo')
        mc=metaclass(mappingObj.MappedTo);
        isMapped=~isempty(mappingObj.MappedTo);
        if isMapped&&isa(mappingObj.MappedTo,'Simulink.DataReferenceClass')
            props=mappingObj.MappedTo.getCSCAttributeNames(modelH);
            props{end+1}='Identifier';
        end
        if isMapped&&isa(mappingObj.MappedTo,'Simulink.AutosarTarget.PortElement')


            hasMappingAndComSpecs=...
            ~(isempty(mappingObj.MappedTo.DataAccessMode)||...
            isempty(mappingObj.MappedTo.Port)||...
            isempty(mappingObj.MappedTo.Element));
        end
        if isa(mappingObj.MappedTo,'Simulink.AutosarTarget.PortEvent')

            mc=metaclass(Simulink.AutosarTarget.PortProvidedEvent);
        end
    else
        mc=metaclass(mappingObj);
        isMapped=mappingObj.isvalid();
    end
    for ii=1:numel(mc.PropertyList)
        prop=mc.PropertyList(ii);
        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
            props{end+1}=prop.Name;%#ok<AGROW>
        end
    end
    if strcmp(mc.Name,'Simulink.AutosarTarget.PortMethod')&&...
        slfeature('AUTOSARMethodsFireAndForgetMapping')
        props{end+1}='FireAndForget';
    end
    if hasMappingAndComSpecs
        props=[props,...
        autosar.ui.comspec.ComSpecPropertyHandler.getValidComSpecPropertiesFromDAM(...
        mappingObj.MappedTo.DataAccessMode)];
    end
end
