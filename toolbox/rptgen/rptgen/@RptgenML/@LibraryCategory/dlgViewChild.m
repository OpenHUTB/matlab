function c=dlgViewChild(this,childComp)






    if ischar(childComp)
        childComp=find(this,'ClassName',childComp);
    end
    if~isempty(childComp)

        e=getEditor(RptgenML.Root);

        if~this.Expanded
            exploreAction(this);
        end

        ime=DAStudio.imExplorer(e);
        ime.selectListViewNode(childComp);

    end


