function setInstanceSpecificProperty(modelH,params,mapping,dataRef,member)






    if~isempty(dataRef)
        instSpecificPropertyNames=fieldnames(params);
        instSpecificPropertyValues=struct2cell(params);
        instanceSpecificProperties=dataRef.getCSCAttributeNames(modelH);
        instanceSpecificProperties=setdiff(instanceSpecificProperties,dataRef.getPerInstanceAttributeNames,'stable');
        for ii=1:numel(instSpecificPropertyNames)
            propertyName=instSpecificPropertyNames{ii};
            if~ismember(propertyName,instanceSpecificProperties)
                DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
            end
        end
        for ii=1:numel(instSpecificPropertyNames)
            value=instSpecificPropertyValues{ii};
            if isa(value,'logical')
                value=int2str(value);
            end
            storageClass=mapping.DefaultsMapping.getGroupNameFromUuid(dataRef.StorageClass.UUID);
            message=mapping.DefaultsMapping.setPerInstanceProperty(member,...
            storageClass,instSpecificPropertyNames{ii},value);
            if~isempty(message)
                error(message);
            end
        end
    end
end


