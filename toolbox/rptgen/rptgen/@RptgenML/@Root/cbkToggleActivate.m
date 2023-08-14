function cbkToggleActivate(this,currComp)





    if(nargin<2)
        currComp=this.getCurrentComponent;
    end

    if(isempty(currComp)||~isa(currComp,'rptgen.rptcomponent'))
        return
    end

    currComp.Active=~currComp.Active;
    currComp.setDirty;

    if isa(this.Editor,'DAStudio.Explorer')

        ime=DAStudio.imExplorer;
        ime.setHandle(this.Editor);

        if~currComp.Active
            ime.collapseTreeNode(currComp);
        else
            ime.expandTreeNode(currComp);
        end


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',currComp);

    end