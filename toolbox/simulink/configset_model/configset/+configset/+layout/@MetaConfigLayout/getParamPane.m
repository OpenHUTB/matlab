function out=getParamPane(obj,name,varargin)
    if~obj.MetaCS.isValidParam(name)
        g=obj.getWidgetGroup(name,true);
    elseif nargin==3
        g=obj.getParamGroup(name,varargin{1});
    else
        g=obj.getParamGroup(name);
    end
    while~strcmp(g.Type,'pane')
        parentName=obj.getParentGroupName(g.Name);
        g=obj.getGroup(parentName);
    end
    out=g;

