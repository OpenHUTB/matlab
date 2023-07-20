function setInstanceSpecificProperty(modelH,params,mapping,dataRef,member)





    if~isempty(dataRef)
        instSpecificPropertyNames=fieldnames(params);
        instSpecificPropertyValues=struct2cell(params);
        instanceSpecificProperties=dataRef.getCSCAttributeNames(modelH);
        for ii=1:numel(instSpecificPropertyNames)
            attributeName=instSpecificPropertyNames{ii};
            if~ismember(attributeName,instanceSpecificProperties)
                DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
            end
        end
        for ii=1:numel(instSpecificPropertyNames)
            storageClass=mapping.DefaultsMapping.getGroupNameFromUuid(dataRef.StorageClass.UUID);
            message=mapping.DefaultsMapping.setPerInstanceProperty(member,storageClass,...
            instSpecificPropertyNames{ii},instSpecificPropertyValues{ii});
            if~isempty(message)
                error(message);
            end
        end
    end
end


