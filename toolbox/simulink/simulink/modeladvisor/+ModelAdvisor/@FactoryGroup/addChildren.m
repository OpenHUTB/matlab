function addChildren(this,childObj,varargin)



    if nargin==3&&strcmp(varargin{1},'connect_only')




        addChildren@matlab.mixin.internal.TreeNode(this,childObj);
    elseif(isa(childObj,'ModelAdvisor.FactoryGroup'))
        this.ChildrenObj{end+1}=childObj;
        this.Children{end+1}=childObj.ID;
    else
        this.Children{end+1}=childObj;
    end
