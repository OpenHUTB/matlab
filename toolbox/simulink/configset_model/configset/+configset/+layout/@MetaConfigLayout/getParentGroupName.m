function out=getParentGroupName(obj,groupID)


    out=[];
    if~obj.ParentGroupMap.isKey(groupID)
        return;
    end
    groups=obj.ParentGroupMap(groupID);
    if iscell(groups)
        for i=1:length(groups)
            if~isempty(obj.getGroup(groups{i}))
                out=groups{i};
                return;
            end
        end
    else
        if~isempty(obj.getGroup(groups))
            out=groups;
        end
    end
end

