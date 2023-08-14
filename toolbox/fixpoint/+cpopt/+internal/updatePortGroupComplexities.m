function updatePortGroupComplexities(blkObj,autoscaler,uid2gID,groupId2GroupInfo)




    portComplexity=blkObj.CompiledPortComplexSignals;
    if isempty(portComplexity)
        return
    end
    outportComplexity=portComplexity.Outport;
    for portIndex=1:length(outportComplexity)
        if outportComplexity(portIndex)

            portPath=autoscaler.getPortMapping(blkObj,[],portIndex);
            id=cpopt.internal.getGroupId(blkObj,portPath,uid2gID);
            if~isempty(id)
                groupInfo=groupId2GroupInfo(id);
                groupInfo.setComplex();
            end
        end
    end
end