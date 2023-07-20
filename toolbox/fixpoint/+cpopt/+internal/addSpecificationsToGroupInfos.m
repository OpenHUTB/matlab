function addSpecificationsToGroupInfos(specs,groupId2GroupInfo)




    for specIndex=1:length(specs)
        spec=specs{specIndex};
        typeContainer=parseDataType(spec.Element.Value);
        type=typeContainer.ResolvedType;
        if~isempty(type)
            groupInfo=groupId2GroupInfo(spec.Group.id);
            groupInfo.setType(type.SlopeAdjustmentFactor,type.Bias);
        end
    end
end