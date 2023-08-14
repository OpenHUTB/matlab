function uuid=getGroupUuidFromName(modelName,name)








    mapping=Simulink.CodeMapping.get(modelName,'CoderDictionary');
    uuid=mapping.DefaultsMapping.getGroupUuidFromName(name);
    if isempty(uuid)
        DAStudio.error('coderdictionary:mapping:NoGroupInDictionary',name);
    end
end
