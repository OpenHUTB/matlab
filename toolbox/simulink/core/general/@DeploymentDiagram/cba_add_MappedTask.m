function cba_add_MappedTask(explorerid)





    me=DeploymentDiagram.getexplorer('ID',explorerid);
    currTreeNode=me.imme.getCurrentTreeNode;
    if isa(currTreeNode,'DAStudio.DAObjectProxy')
        currTreeNode=currTreeNode.getMCOSObjectReference();
    end
    assert(isa(currTreeNode,...
    'Simulink.DistributedTarget.Mapping'));
    currNode_=me.imme.getSelectedListNodes;

    if isa(currNode_,'DAStudio.DAObjectProxy')
        currNode_=currNode_.getMCOSObjectReference;
    end


    if(isa(currNode_,'DAStudio.Group')&&(strcmp(currNode_.Name,'Block')))
        maps=currTreeNode.getChildren;
        idx=find(strcmp({maps.BlockName},currNode_.Value));
        if isempty(idx),return;end
        currNode=maps(idx(end));
    elseif isa(currNode_,...
        'Simulink.SoftwareTarget.BlockToTaskMapping_Explorer')
        currNode=currNode_;
    else
        return;
    end

    currNode.addMapBehindThisOne();
    DeploymentDiagram.fireHierarchyChange(currTreeNode);

    lst=me.findNodes('Maps');
    idx=arrayfun(@(x)(x.Block==currNode.Block),lst);
    idx=find(idx);
    idx=idx(end);
    me.imme.selectListViewNode(lst(idx));

