function groupId2GroupInfo=createGroupIdToGroupInfoMap(activeGroups,inactiveGroups)




    groupId2GroupInfo=containers.Map('KeyType','double','ValueType','any');
    for groupIndex=1:length(activeGroups)
        group=activeGroups{groupIndex};
        groupId2GroupInfo(group.id)=cpopt.internal.GroupInfo(num2str(group.id),true);
    end
    for groupIndex=1:length(inactiveGroups)
        group=inactiveGroups{groupIndex};
        groupId2GroupInfo(group.id)=cpopt.internal.GroupInfo(num2str(group.id),false);
    end


    dummyGroup=cpopt.internal.GroupInfo('Default',false);
    dummyGroup.setType(1.0,0.0);
    groupId2GroupInfo(-1)=dummyGroup;
end