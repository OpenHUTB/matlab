function cbe_refreshactions(h,e)






    me=h;

    currTreeNode=me.imme.getCurrentTreeNode;

    if isvector(e.EventData)&&strcmp(class(e.EventData),'handle')
        if(strcmp(e.Type,'MEListSelectionChanged')&&...
            ~isempty(currTreeNode)&&...
            isa(currTreeNode,'DeploymentDiagram.Node'))
            h.updateactions('off',currTreeNode.getactions);
        end
        return;
    end

    if~isempty(me)&&~isempty(me.getRoot)&&~isempty(e.EventData)

        ac=h.getActionsForSelectedNode(e.EventData,currTreeNode);

        h.lastSelectedNodeActions=ac;
        h.updateactions('off',ac);
        if strcmp(e.Type,'METreeSelectionChanged')
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',e.EventData);
        end

    end

