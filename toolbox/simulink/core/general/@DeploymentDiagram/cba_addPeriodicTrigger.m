function cba_addPeriodicTrigger(explorerid)






    me=DeploymentDiagram.getexplorer('ID',explorerid);

    currTreeNode=me.imme.getCurrentTreeNode;

    isSoftwareNode=isa(currTreeNode,'Simulink.DistributedTarget.SoftwareNode');
    isTaskConfiguration=isa(currTreeNode,'Simulink.SoftwareTarget.TaskConfiguration');
    isPeriodicTrigger=isa(currTreeNode,'Simulink.SoftwareTarget.PeriodicTrigger');
    isMapping=isa(currTreeNode,'Simulink.DistributedTarget.Mapping');



    softwareNodes=me.findNodes('SoftwareNode');

    softwareNode=softwareNodes(1);




    for i=1:length(softwareNodes)
        if me.isChildNode(currTreeNode,softwareNodes(i))
            softwareNode=softwareNodes(i);
            break;
        end
    end
    mCosHdl=softwareNode.TaskConfiguration;
    tname=getUniqueTaskGroupName({mCosHdl.TaskGroups.Name});
    periodicTaskGroupNode=mCosHdl.addTrigger(tname,'PeriodicTrigger');


    if(isTaskConfiguration||isSoftwareNode||isPeriodicTrigger||isMapping)
        me.imme.selectTreeViewNode(periodicTaskGroupNode);
    else
        me.imme.expandTreeNode(softwareNode);
    end


    function name=getUniqueTaskGroupName(names)

        baseName='Periodic';
        name=baseName;
        idx=1;

        while true
            if any(strcmp(name,names))
                name=sprintf('%s%d',baseName,idx);
                idx=idx+1;
            else
                break;
            end
        end



