function cba_addAperiodicTG(explorerid)






    me=DeploymentDiagram.getexplorer('ID',explorerid);
    currTreeNode=me.imme.getCurrentTreeNode;
    currObj=currTreeNode;
    isSoftwareNode=isa(currObj,'Simulink.DistributedTarget.SoftwareNode');
    isTaskConfiguration=isa(currObj,'Simulink.SoftwareTarget.TaskConfiguration');
    isAperiodicEH=isa(currObj,'Simulink.SoftwareTarget.AperiodicTrigger');
    isMapping=isa(currObj,'Simulink.DistributedTarget.Mapping');


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
    aperiodicTaskGroupNode=mCosHdl.addAperiodicTaskGroup(tname);


    if(isTaskConfiguration||isSoftwareNode||isAperiodicEH||isMapping)
        me.imme.selectTreeViewNode(aperiodicTaskGroupNode);
    else
        me.imme.expandTreeNode(softwareNode);
    end


    function name=getUniqueTaskGroupName(names)

        baseName='Interrupt';
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

