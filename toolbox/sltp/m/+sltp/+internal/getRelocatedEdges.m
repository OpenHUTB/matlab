function edges=getRelocatedEdges(mdlHdl,tasks,newParent)

    tcg=sltp.TaskConnectivityGraph(get_param(mdlHdl,'name'));
    edges.added={};
    edges.deleted={};
    for idx=1:length(tasks)
        edges.added=[edges.added,tcg.getRelocatedEdges(tasks{idx},newParent)'];
        edges.deleted=[edges.deleted,tcg.getRelocatedDeletions(tasks{idx},newParent)'];
    end
end
