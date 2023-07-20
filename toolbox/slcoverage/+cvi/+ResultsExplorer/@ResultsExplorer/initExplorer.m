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
    e.delegateClose=true;

    melistener1=handle.listener(e,'MEDelete',{@closeCallback});

    melistener2=handle.listener(e,'MEPostClosed',{@hideCallback});
    melistener3=handle.listener(e,'METreeExpanded',{@treeExpandedCallback});
    melistener4=handle.listener(e,'METreeSelectionChanged',{@treeSelectionCallback});
    this.listeners={melistener1,melistener2,melistener3,melistener4};


    this.imme=DAStudio.imExplorer(e);
    this.imme.setHandle(e);
    this.am=DAStudio.ActionManager;
    this.am.initializeClient(e);
    this.ed=DAStudio.EventDispatcher;
end

function treeSelectionCallback(this,e)
    treeExpandedCallback(this,e);
end


function treeExpandedCallback(this,e)
    tree=e.EventData.m_impl;
    re=this.getRoot.m_impl.resultsExplorer;
    if isa(tree,'cvi.ResultsExplorer.Tree')
        cvi.ResultsExplorer.ResultsExplorer.treeExpandedCallback(re,tree);
    elseif startsWith(class(tree),'cvi.FilterExplorer')
        cvi.FilterExplorer.FilterExplorer.treeExpandedCallback(tree);
    end

end

function hideCallback(this,e)
    cvi.ResultsExplorer.ResultsExplorer.hide(this.getRoot.m_impl.resultsExplorer.topModelName);
end

function closeCallback(this,e)
    cvi.ResultsExplorer.ResultsExplorer.close(this.getRoot.m_impl.resultsExplorer.topModelHandle);
end