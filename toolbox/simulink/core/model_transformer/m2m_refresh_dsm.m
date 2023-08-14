function m2m_refresh_dsm(mdladvObj)




    immodelExplorer=DAStudio.imExplorer(mdladvObj.MAExplorer);
    selectedNode=Advisor.Utils.convertMCOS(immodelExplorer.getCurrentTreeNode);
    eventdispatcher=DAStudio.EventDispatcher;
    eventdispatcher.broadcastEvent('PropertyChangedEvent',selectedNode);
end
