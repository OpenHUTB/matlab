function obj=getSelectedListNodes(this,firstOnly)




    ime=DAStudio.imExplorer(getEditor(this));
    obj=ime.getSelectedListNodes;

    if nargin>1&&firstOnly&&~isempty(obj)
        obj=obj(1);
    end
