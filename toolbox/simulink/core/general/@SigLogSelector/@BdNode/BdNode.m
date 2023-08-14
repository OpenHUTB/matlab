function h=BdNode(mdlName,bDelayLoad)





    bd=[];
    if nargin>0&&(nargin<2||~bDelayLoad)
        bd=get_param(mdlName,'Object');
    end


    if isempty(bd)
        h=SigLogSelector.BdNode;
    else
        h=SigLogSelector.createSubSystem(bd);
        h.validateOverrideSettings;
        h.populate;
        h.fireHierarchyChanged;
    end


    if nargin>1&&bDelayLoad
        h.Name=mdlName;
        h.CachedFullName=mdlName;
        h.daobject=[];
    end

end

