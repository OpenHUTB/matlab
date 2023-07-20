function out=getGroup(obj,groupID)


    if~obj.GroupObjectMap.isKey(groupID)
        out=[];
    else
        groups=obj.GroupObjectMap(groupID);
        out=[];
        if length(groups)>1
            for i=1:length(groups)
                if groups(i).isFeatureActive
                    out=groups(i);
                end
            end
        else
            if groups.isFeatureActive
                out=groups;
            end
        end
    end

