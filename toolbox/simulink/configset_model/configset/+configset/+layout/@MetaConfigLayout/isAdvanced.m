function ret=isAdvanced(obj,name)



    group=obj.getWidgetGroup(name);
    if isempty(group)

        group=obj.getGroup(name);
    end
    if~isempty(group)
        ret=loc_isAdvancedGroup(obj,group);
    else
        ret=false;
    end

    function ret=loc_isAdvancedGroup(obj,group)

        ret=false;
        if isempty(group)
            return;
        else
            if group.Advanced
                ret=true;
                return;
            else
                if obj.ParentGroupMap.isKey(group.Name)
                    parent=obj.getParentGroupName(group.Name);
                    ret=loc_isAdvancedGroup(obj,obj.getGroup(parent));
                else
                    return;
                end
            end
        end

