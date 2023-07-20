function expandChildren(this,thisNode,ime)





    if~isa(this.Editor,'DAStudio.Explorer')
        return
    end

    if((nargin<3)||isempty(ime))
        ime=DAStudio.imExplorer;
        ime.setHandle(this.Editor);
    end

    if((nargin<2)||isempty(thisNode))
        thisNode=this;
    end


    childNodes=getHierarchicalChildren(thisNode);
    if~isempty(childNodes)
        for i=1:length(childNodes)
            try
                updateErrorState(childNodes(i));
            catch

            end
        end

        if(isa(thisNode,'rptgen.rptcomponent')&&~thisNode.active)
            ime.collapseTreeNode(thisNode);
        else
            ime.expandTreeNode(thisNode);
        end

        for i=1:length(childNodes)
            this.expandChildren(childNodes(i),ime);
        end
    end