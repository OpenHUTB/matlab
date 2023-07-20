function out=coderDictionaryMigrationHandler(command,model,~)







    switch command
    case 'migrate'

    end

    mmgr=get_param(model,'MappingManager');
    mappingType=mmgr.getCurrentMapping();
    modelMapping=[];
    if~isempty(mappingType)
        modelMapping=mmgr.getActiveMappingFor(mappingType);
    end
    out=~isempty(modelMapping)&&isequal(mappingType,'CoderDictionary');

end
