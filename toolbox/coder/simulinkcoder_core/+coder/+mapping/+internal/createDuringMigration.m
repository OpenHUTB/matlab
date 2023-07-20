function createDuringMigration(modelH,configSet,varargin)








    if~isempty(varargin)
        mappingType=varargin{:};
    else
        mappingType='';
    end
    [~,currentMappingType]=Simulink.CodeMapping.getCurrentMapping(modelH);
    if(strcmp(mappingType,'CoderDictionary')&&~strcmp(currentMappingType,mappingType))


        coder.mapping.internal.createCoderDictionaryAndMappingForERT(modelH);
    else
        coder.mapping.internal.create(modelH,configSet,'noSharedDictionary',true);
    end
