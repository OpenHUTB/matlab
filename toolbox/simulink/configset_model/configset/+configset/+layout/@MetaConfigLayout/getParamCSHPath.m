function cshpath=getParamCSHPath(obj,name)
    g=obj.getParamGroup(name);
    while isempty(g.CSHPath)&&~isempty(obj.getParentGroupName(g.Name))
        if isempty(obj.getGroup(obj.getParentGroupName(g.Name)))
            break;
        end
        parentName=obj.getParentGroupName(g.Name);
        g=obj.getGroup(parentName);
    end
    cshpath=g.CSHPath;

