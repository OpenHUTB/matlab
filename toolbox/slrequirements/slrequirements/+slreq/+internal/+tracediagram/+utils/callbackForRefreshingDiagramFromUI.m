function graphData=callbackForRefreshingDiagramFromUI(targetViewId)


    dmgr=slreq.internal.tracediagram.utils.DiagramManager.getInstance;

    graph=dmgr.generateGraphFromViewId(targetViewId);

    graphData=graph.export();
end