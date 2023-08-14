function generateTraceDiagramByNode(domain,artifact,id)






    item.domain=domain;
    item.artifactUri=artifact;
    item.id=id;
    dmgr=slreq.internal.tracediagram.utils.DiagramManager.getInstance;
    dmgr.openWindow(item);
end
