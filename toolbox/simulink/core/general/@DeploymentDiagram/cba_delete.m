function cba_delete(explorerid)





    me=DeploymentDiagram.getexplorer('ID',explorerid);
    currTreeObj=me.imme.getCurrentTreeNode;



    if isempty(currTreeObj)
        return;
    end
    selListNode=me.imme.getSelectedListNodes;
    if iscell(selListNode)
        selListNode=[selListNode{:}]';
    end
    if isa(currTreeObj,'Simulink.SoftwareTarget.PeriodicTrigger')
        selectedTaskNodes=me.imme.getSelectedListNodes;
        if iscell(selectedTaskNodes)
            selectedTaskNodes=[selectedTaskNodes{:}]';
        end
        if isempty(selectedTaskNodes)
            if~DeploymentDiagram.canDeletePeriodicTrigger(currTreeObj)
                errordlg(DAStudio.message('Simulink:taskEditor:PeriodicTaskGroupDeleteText'),...
                'Error','replace');
            else
                deleteThisTaskGroup(currTreeObj);
            end
        else
            for i=1:length(selectedTaskNodes)
                deleteThisTask(selectedTaskNodes(i));
            end
        end



        me.updateactions('off',DeploymentDiagram.getactions(currTreeObj));

    elseif isa(currTreeObj,'Simulink.SoftwareTarget.TaskConfiguration')

        if isempty(selListNode)

            assert(false);
        elseif isa(selListNode,'Simulink.SoftwareTarget.AperiodicTrigger')

            for i=1:length(selListNode)
                deleteThisTaskGroup(selListNode(i));
            end
            me.updateactions('off',DeploymentDiagram.getactions(currTreeObj));
        end

    elseif isa(currTreeObj,'Simulink.SoftwareTarget.AperiodicTrigger')
        deleteThisTaskGroup(currTreeObj);
    elseif isa(currTreeObj,'Simulink.SoftwareTarget.Task')
        deleteThisTask(currTreeObj);

    elseif isa(currTreeObj,'Simulink.DistributedTarget.Mapping')
        selectedMapNode=me.imme.getSelectedListNodes;

        if isempty(selectedMapNode)
            errordlg(DAStudio.message('Simulink:taskEditor:MappingDeleteText'),...
            'Error','replace');
        end
        deleteThisTaskMap(me,selectedMapNode,currTreeObj);



        if~isempty(me.imme.getSelectedListNodes)
            activeNode=me.imme.getSelectedListNodes;
            me.updateactions('off',DeploymentDiagram.getactions(activeNode));
        else
            me.updateactions('off',DeploymentDiagram.getactions(currTreeObj));
        end
    end


    function deleteThisTask(h)







        mCosHdl=h.ParentTaskGroup;
        mCosHdl.deleteTask(h);


        function deleteThisTaskGroup(h)








            mCosHdl=h.ParentTaskConfiguration;
            mCosHdl.deleteTaskGroup(h);

            function deleteThisTaskMap(me,blockTaskPairLstNode,mappingTreeNode)
                if isa(blockTaskPairLstNode,'DAStudio.DAObjectProxy')
                    blockTaskPairLstNode=blockTaskPairLstNode.getMCOSObjectReference;
                end
                blkH=blockTaskPairLstNode.Block;
                blockTaskPairLstNode.eraseThisMap();
                DeploymentDiagram.fireHierarchyChange(mappingTreeNode);

                lst=me.findNodes('Maps');
                idx=arrayfun(@(x)(x.Block==blkH),lst);
                idx=find(idx);
                idx=idx(1);
                me.imme.selectListViewNode(lst(idx));



