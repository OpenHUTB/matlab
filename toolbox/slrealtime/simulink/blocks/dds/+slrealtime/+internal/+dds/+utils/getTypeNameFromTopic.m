function typeName=getTypeNameFromTopic(modelName,fullPathToTopic)






    typeName='';
    [~,~,dd]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
    if~isempty(dd)
        topic=dds.internal.simulink.Util.getTopic(modelName,fullPathToTopic);
        if~isempty(topic)
            typeName=dds.internal.getFullNameForType(topic.RegisterTypeRef.TypeRef);
        end
    end

end
