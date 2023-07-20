function cba_addtask(explorerid)





    me=DeploymentDiagram.getexplorer('ID',explorerid);
    currTreeNode=me.imme.getCurrentTreeNode;

    isPeriodicTriggerNode=isa(currTreeNode,'Simulink.SoftwareTarget.PeriodicTrigger');
    isAperiodicTriggerNode=isa(currTreeNode,'Simulink.SoftwareTarget.AperiodicTrigger');
    isTaskNode=isa(currTreeNode,'Simulink.SoftwareTarget.Task');
    isSoftwareNode=isa(currTreeNode,'Simulink.DistributedTarget.SoftwareNode');
    isTaskGroupNode=(isPeriodicTriggerNode||isAperiodicTriggerNode);
    isTaskOrTaskGroup=(isTaskGroupNode||isTaskNode);






    periodicEH=me.findNodes('Periodic');
    TaskGroupNode=periodicEH(1);
    if(isTaskGroupNode)
        TaskGroupNode=currTreeNode;
    elseif isSoftwareNode
        childNodes=currTreeNode.getHierarchicalChildren;
        if(~isempty(childNodes))
            TaskGroupNode=childNodes(1);
        end
    elseif isTaskNode
        for i=1:length(periodicEH)
            if me.isChildNode(currTreeNode,periodicEH(i))
                TaskGroupNode=periodicEH(i);
                break;
            end
        end
    end



    if numel(TaskGroupNode.getChildren)>=1
        names={TaskGroupNode.Tasks.Name};
        tname=names{end};
    else
        tname='Task';
    end
    t=TaskGroupNode.addTask(tname);

    DeploymentDiagram.fireHierarchyChange(TaskGroupNode);

    if(isTaskOrTaskGroup)
        me.imme.selectTreeViewNode(t);

    else
        me.tree_expandnodes(TaskGroupNode);
    end



