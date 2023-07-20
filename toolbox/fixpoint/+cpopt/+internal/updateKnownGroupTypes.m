function updateKnownGroupTypes(blkObj,autoscaler,uid2gID,groupId2GroupInfo)




    portTypes=blkObj.CompiledPortDataTypes;
    if isempty(portTypes)
        return
    end
    outportTypes=portTypes.Outport;
    for portIndex=1:length(outportTypes)
        portType=outportTypes{portIndex};
        portPath=autoscaler.getPortMapping(blkObj,[],portIndex);
        if~isempty(portPath)
            id=cpopt.internal.getGroupId(blkObj,portPath,uid2gID);
            groupInfo=groupId2GroupInfo(id);

            if~groupInfo.isProposable()&&~groupInfo.isKnown()
                typeContainer=parseDataType(portType,blkObj);
                type=typeContainer.ResolvedType;
                if~isempty(type)
                    groupInfo.setType(type.SlopeAdjustmentFactor,type.Bias);
                end
            end
        end
    end
end