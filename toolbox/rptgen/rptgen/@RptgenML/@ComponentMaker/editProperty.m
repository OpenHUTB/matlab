function editProperty(this,propIdx)







    if nargin<2
        propIdx=this.DlgCurrentPropertyIdx;
    end

    try
        vProp=this.getHierarchicalChildren;
        vProp=vProp(propIdx);
        vProp.view;
    end
