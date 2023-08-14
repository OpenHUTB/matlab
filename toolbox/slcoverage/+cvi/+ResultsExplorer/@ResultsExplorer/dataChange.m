function dataChange(~,node)




    obj=node.parentTree.resultsExplorer;
    obj.ed.broadcastEvent('HierarchyChangedEvent',node.interface);

    if~isempty(node.srcNode)
        obj.ed.broadcastEvent('HierarchyChangedEvent',node.srcNode.interface);
    elseif~isempty(node.data)&&~isempty(node.data.dstNode)
        obj.ed.broadcastEvent('HierarchyChangedEvent',node.data.dstNode.interface);
    end
    activeDlg=obj.imme.getDialogHandle;
    if~isempty(activeDlg)&&strcmpi(activeDlg.getTitle,getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageData')))
        activeDlg.refresh();
    end

end