function allowedValues=getAllowedValues(model,elementType,attribute)













    mmgr=get_param(model,'MappingManager');
    mappingType=mmgr.getCurrentMapping();
    if~(strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'SimulinkCoderCTarget'))
        disp('Only C Mappings are supported');
        return
    end
    mappingInfo=mmgr.getActiveMappingFor(mappingType);
    switch attribute
    case 'StorageClass'
        allowedValues=mappingInfo.DefaultsMapping.getAllowedGroupNames(elementType,'IndividualLevel');
    case 'MemorySection'
        allowedValues=mappingInfo.DefaultsMapping.getAllowedMemorySectionNames(elementType,'IndividualLevel');
    otherwise
        disp('Wrong coder data attribute specified');
    end

end
