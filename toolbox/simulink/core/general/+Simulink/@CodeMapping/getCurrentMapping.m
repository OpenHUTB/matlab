function[modelMapping,mappingType]=getCurrentMapping(sourceModel)




    mmgr=get_param(sourceModel,'MappingManager');
    mappingType=mmgr.getCurrentMapping();
    modelMapping=[];
    if~isempty(mappingType)
        modelMapping=mmgr.getActiveMappingFor(mappingType);
    end
end
