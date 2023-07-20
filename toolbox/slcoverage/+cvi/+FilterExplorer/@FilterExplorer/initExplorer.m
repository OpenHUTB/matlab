function initExplorer(this,root)




    eTitle=this.dialogTitle;
    e=DAStudio.Explorer(root,eTitle,false);
    this.explorer=e;
    e.Title=eTitle;

    e.setTreeTitle('');
    e.allowWholeRowDblClick=false;
    e.showContentsOf(false);
    e.showDialogView(true);
    e.showListView(false);


    this.listeners{1}=handle.listener(e,'MEDelete',{@deleteCallback});
    this.listeners{2}=handle.listener(e,'MEPostClosed',{@closeCallback});
    this.listeners{3}=handle.listener(e,'METreeExpanded',{@treeExpandedCallback});
    this.listeners{4}=handle.listener(e,'METreeSelectionChanged',{@treeSelectionCallback});

    this.imme=DAStudio.imExplorer(e);
    this.imme.setHandle(e);
    this.am=DAStudio.ActionManager;
    this.am.initializeClient(e);
    this.ed=DAStudio.EventDispatcher;
end

function treeSelectionCallback(this,e)
    treeExpandedCallback(this,e);
end


function treeExpandedCallback(~,e)
    node=e.EventData.m_impl;
    cvi.FilterExplorer.FilterExplorer.treeExpandedCallback(node);

end

function deleteCallback(this,~)
    if~ishandle(this)
        return;
    end
    filterExplorer=this.getRoot.m_main;
    if~isvalid(filterExplorer)
        return;
    end
    cvi.FilterExplorer.FilterExplorer.instanceMap(filterExplorer.ctxId,[]);
    cvi.FilterExplorer.FilterExplorer.destroy(filterExplorer);
end

function closeCallback(this,~)
    filterExplorer=this.getRoot.m_main;
    cvi.FilterExplorer.FilterExplorer.close(filterExplorer);
end

