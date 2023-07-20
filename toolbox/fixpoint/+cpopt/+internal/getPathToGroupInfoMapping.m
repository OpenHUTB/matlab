function pathItemToGroupInfo=getPathToGroupInfoMapping(pathItemToGroupId,id2GroupInfo)







    pathItemToGroupInfo=containers.Map();

    pathItems=pathItemToGroupId.keys;
    for i=1:length(pathItems)
        pathItem=pathItems{i};
        id=pathItemToGroupId(pathItem);
        pathItemToGroupInfo(pathItem)=id2GroupInfo(id);
    end
end

