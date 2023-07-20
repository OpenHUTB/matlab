function actions=getActionsForSelectedNode(~,selectedNode,currTreeNode)





    if isa(selectedNode,'DAStudio.Group')
        if strcmp(selectedNode.Name,'Block')



            actions=getActionsForBlockGroup(selectedNode,currTreeNode);
        else



            actions={'ADD_APERIODIC_TASKG','ADD_TASK',...
            'ADD_MAPPED_TASK','EDIT_DELETE',...
            'ADD_PERIODIC_TRIGGER'};
        end

    else
        actions=DeploymentDiagram.getactions(selectedNode);
    end


    function ac=getActionsForBlockGroup(selectedNode,mappingNode)


        ac={};
        if isa(mappingNode,"DAStudio.DABaseObject")
            mappingNode=mappingNode.getMCOSObjectReference();
        end
        maps=mappingNode.getChildren;
        idx=find(strcmp({maps.BlockName},selectedNode.Value));
        if~isempty(idx)
            m=maps(idx(1));
            blkHandle=get_param(m.Block,'Handle');
            if DeploymentDiagram.isBlockAsyncMappable(blkHandle)
                ac{end+1}='ADD_MAPPED_TASK';
            end
            ac{end+1}='EDIT_DELETE';
        end


