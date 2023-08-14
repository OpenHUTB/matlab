function toggleSourcetab




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    memenus=mdladvObj.MEmenus;
    if isfield(memenus,'ViewSourcetab')&&isprop(memenus.ViewSourcetab,'on')
        if strcmp(memenus.ViewSourcetab.on,'on')
            mdladvObj.ShowSourceTab=true;
        else
            mdladvObj.ShowSourceTab=false;
        end
        imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
        selectedNode=imme.getCurrentTreeNode;
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',selectedNode);
    end
