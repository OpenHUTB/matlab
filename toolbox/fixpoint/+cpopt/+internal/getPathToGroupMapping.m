function pathItemToGroupId=getPathToGroupMapping(blkObj,autoscaler,key2gID)




    pathItemToGroupId=containers.Map;

    pathItems=autoscaler.getPathItems(blkObj);
    for pathItemIndex=1:length(pathItems)
        pathItem=pathItems{pathItemIndex};
        pathGroupId=cpopt.internal.getGroupId(blkObj,pathItem,key2gID);
        pathItemToGroupId(pathItem)=pathGroupId;
    end
end