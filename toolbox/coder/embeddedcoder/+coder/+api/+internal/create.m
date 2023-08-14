function codeMapping=create(sourceObj,configSet)




    if~strcmp(get_param(sourceObj.modelH,'IsERTTarget'),'on')
        DAStudio.error('coderdictionary:api:supportedForErt');
    end
    mapping=Simulink.CodeMapping.get(sourceObj.modelH,'CoderDictionary');
    modelName=get_param(sourceObj.modelH,'Name');
    if isempty(mapping)
        Simulink.CodeMapping.addCoderGroups(modelName,'init');
        Simulink.CodeMapping.create(modelName,'default','CoderDictionary');
    end
    if~isempty(configSet)
        Simulink.CodeMapping.doMigrationFromGUI(modelName,false);
    end
    codeMapping=coder.api.CodeMapping(sourceObj);
end


